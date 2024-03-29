from django.conf import settings
import redis

redis_client = redis.StrictRedis(
    host='redis_db', port=settings.REDIS_PORT, db=settings.REDIS_DB)


def handle_message(message):
    # Maneja el mensaje recibido
    print("Mensaje recibido:", message)


def subscribe_channel(channel):
    try:
        pubsub = redis_client.pubsub()
        pubsub.subscribe(channel)
        print("Escuchando canal:", channel)
        for message in pubsub.listen():
            if message['type'] == 'message':
                handle_message(message['data'])
    except Exception as e:
        print("Error al suscribirse al canal:", e)
