from django.conf import settings
import redis
from typing import List
from app_admin.adapters.messaging.callback_observer import CallbackObserver
from app_admin.adapters.messaging.redis.client import RedisClient


class Subscribe:
    def __init__(self, channel, observers: List[CallbackObserver]):
        self.redis_client = RedisClient(
            settings.REDIS_HOST, settings.REDIS_PORT, settings.REDIS_DB
        )
        self.observers = observers
        self.channel = channel

    def subscribe_channel(self):
        try:
            pubsub = self.redis_client.pubsub()
            pubsub.subscribe(self.channel)
            for message in pubsub.listen():

                for observer in self.observers:
                    print("Mensaje recibido:  ", message)
                    if message['type'] == 'message':
                        observer.update(message, observer.channel)

        except Exception as e:
            print("Error al suscribirse al canal:  ", e)
            raise e


def create_subscription(channel, observers: List[CallbackObserver]):
    print("Creando suscripción")
    subscription = Subscribe(channel, observers)
    subscription.subscribe_channel()
