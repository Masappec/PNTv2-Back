from django.conf import settings

from entity_app.adapters.messaging.redis.client import RedisClient


class Publisher:

    redis_client = None

    channel = None

    def __init__(self, channel):
        self.redis_client = RedisClient(
            settings.REDIS_HOST, settings.REDIS_PORT, settings.REDIS_DB
        )
        self.channel = channel

    def publish(self, message):
        self.redis_client.publish(self.channel, message)
