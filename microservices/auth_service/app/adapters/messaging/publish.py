from django.conf import settings
# publish.py (Microservicio 1)
import uuid
from app.adapters.messaging.redis.client import RedisClient
import json


class Publisher:

    redis_client = None

    channel = None

    def __init__(self, channel):
        self.redis_client = RedisClient(
            settings.REDIS_HOST, settings.REDIS_PORT, settings.REDIS_DB
        )
        self.channel = channel

    def publish(self, message):
        message['id'] = str(uuid.uuid4())

        message = json.dumps(message)
        print(f"Publishing message: {message}")
        self.redis_client.publish(self.channel, message)
