from django.conf import settings
import redis
from typing import List
from entity_app.adapters.messaging.callback_observer import CallbackObserver
from entity_app.adapters.messaging.redis.client import RedisClient


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
            for observer in self.observers:

                for message in pubsub.listen():
                    if message['type'] == 'message':
                        for observer in self.observers:
                            print("Observer: ", observer)
                            observer.update(message, observer.channel)

        except Exception as e:
            print("Error al suscribirse al canal: ", e)
            raise e


def create_subscription(channel: str, observers: List[CallbackObserver]):
    print("Creando suscripción")
    subscription = Subscribe(channel, observers)
    subscription.subscribe_channel()
