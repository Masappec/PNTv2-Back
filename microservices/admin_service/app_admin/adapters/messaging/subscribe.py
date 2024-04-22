from django.conf import settings
import redis
from typing import List
from app_admin.adapters.messaging.callback_observer import CallbackObserver
from app_admin.adapters.messaging.redis.client import RedisClient
import json
import uuid
import time
import random
from threading import Lock


class SubscribeManager:
    _instances = {}
    _lock = Lock()

    @classmethod
    def get_instance(cls, channel, observers: List[CallbackObserver]):
        if channel not in cls._instances:
            with cls._lock:
                if channel not in cls._instances:
                    cls._instances[channel] = Subscribe(channel, observers)
        return cls._instances[channel]


class Subscribe:
    def __init__(self, channel, observers: List[CallbackObserver]):
        self.redis_client = RedisClient(
            settings.REDIS_HOST, settings.REDIS_PORT, settings.REDIS_DB
        )
        self.observers = observers
        self.channel = channel
        # Mantener un conjunto de IDs de mensajes procesados
        self.processed_messages = set()
        with open("log.txt", "a", encoding="utf-8") as file:
            self.file = file

            self.file.write(
                f"{time.ctime()} - Iniciando suscripción al canal {channel}\n")

    def check_subscription(self, channel):

        # Obtiene una lista de los canales a los que el cliente está suscrito
        subscribed_channels = self.redis_client.pubsub_channels()

        # Verifica si el canal de interés ya está en la lista de canales suscritos
        if channel.encode() in subscribed_channels:
            return True
        else:
            return False

    def generate_message_id(self, sender_id):
        timestamp = int(time.time() * 1000)  # Marca de tiempo en milisegundos
        # Utiliza solo los primeros 8 caracteres del UUID
        unique_id = str(uuid.uuid4())[:8]
        return f"{sender_id}_{timestamp}_{unique_id}_{random.randint(0, 1000)}"

    def subscribe_channel(self):
        try:
            pubsub = self.redis_client.pubsub()
            if not self.check_subscription(self.channel):
                pubsub.subscribe(self.channel)
                for message in pubsub.listen():
                    time.sleep(10)
                    if message['type'] == 'message':
                        with open("log.txt", "a", encoding="utf-8") as file:
                            file.write(
                                f"{time.ctime()} - Mensaje recibido: {message}\n")
                        print("Mensaje recibido: ", message)
                        dict_ = json.loads(message['data'])
                        message_id = self.generate_message_id(dict_['id'])

                        # Verificar si el mensaje ya ha sido procesado
                        if not message_id:
                            print("Message does not have an ID. Skipping. ")
                            continue

                        if self.redis_client.get(message_id):
                            print(f"Message with ID  {
                                message_id} already processed. Skipping.")
                            continue
                        # Si el mensaje no ha sido procesado, procesarlo y actualizar el registro
                        print(self.redis_client. get(message_id))

                        observers_affects = []

                        for observer in self.observers:
                            if observer.channel == self.channel and observer.type == dict_['type']:
                                if observer not in observers_affects:
                                    observers_affects.append(observer)

                        print("Observers afectados: ", observers_affects)
                        for observer in observers_affects:
                            self.redis_client.set(message_id, "processed")
                            self.processed_messages.add(message_id)
                            self.redis_client.expire(message_id, 60 * 60 * 24)
                            observer.update(message, observer.channel)

                        # Agregar el ID del mensaje al conjunto de mensajes procesados
            else:
                # eliminar la suscripción
                pubsub.unsubscribe(self.channel)
        except Exception as e:
            print("Error al suscribirse al canal: ", e)


def create_subscription(channel, observers: List[CallbackObserver]):
    manager = SubscribeManager.get_instance(channel, observers)
    manager.observers.extend(observers)
    manager.subscribe_channel()
