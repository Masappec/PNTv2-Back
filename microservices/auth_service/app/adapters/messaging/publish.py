from django.conf import settings
# publish.py (Microservicio 1)

import redis

redis_client = redis.StrictRedis(
    host='redis_db', port=settings.REDIS_PORT, db=settings.REDIS_DB)


def publish_message(channel, message):
    print("Publicando mensaje:", message)
    redis_client.publish(channel, message)
