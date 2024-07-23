from django.conf import settings
import redis
from typing import List
from entity_app.adapters.messaging.callback_observer import CallbackObserver
from entity_app.adapters.messaging.redis.client import RedisClient
import json
import uuid
import time


class Subscribe:
    def __init__(self, channel, observers: List[CallbackObserver]):
        self.redis_client = RedisClient(
            settings.REDIS_HOST, settings.REDIS_PORT, settings.REDIS_DB
        )
        self.observers = observers
        self.channel = channel
        # Mantener un conjunto de IDs de mensajes procesados
        self.processed_messages = set()

    def generate_message_id(self, sender_id):
        timestamp = int(time.time() * 1000)  # Marca de tiempo en milisegundos
        # Utiliza solo los primeros 8 caracteres del UUID
        unique_id = str(uuid.uuid4())[:8]
        return f"{sender_id}_{timestamp}_{unique_id}"

    def subscribe_channel(self):
        try:
            pubsub = self.redis_client.pubsub()
            pubsub.subscribe(self.channel)
            for message in pubsub.listen():
                if message['type'] == 'message':
                    dict_ = json.loads(message['data'])
                    message_id = self.generate_message_id(dict_['id'])

                    # Verificar si el mensaje ya ha sido procesado
                    if not message_id:
                        print("Message does not have an ID. Skipping.")
                        return

                    if self.redis_client.get(message_id):
                        print(f"Message with ID {
                              message_id} already processed. Skipping.")
                        return
                    # Si el mensaje no ha sido procesado, procesarlo y actualizar el registro
                    observers_affects = [observer for observer in self.observers if observer.channel == self.channel
                                         and observer.type == dict_['type']]

                    for observer in observers_affects:
                        observer.update(message, observer.channel)

                    # Agregar el ID del mensaje al conjunto de mensajes procesados
                    self.redis_client.set(message_id, "processed")
                    self.processed_messages.add(message_id)
                    self.redis_client.expire(message_id, 60 * 60 * 24)

        except Exception as e:
            #volvemos a suscribirnos
            self.subscribe_channel()
            print(f"Error subscribing to channel {self.channel}: {e}")
            


def create_subscription(channel, observers: List[CallbackObserver]):
    print("Creando suscripción")
    subscription = Subscribe(channel, observers)
    subscription.subscribe_channel()
