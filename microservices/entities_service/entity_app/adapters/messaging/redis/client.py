import redis


class RedisClient:

    def __init__(self, host, port, db):
        self.host = host
        self.port = port
        self.db = db
        self.client = None
        self.connect()

    def connect(self):
        self.client = redis.StrictRedis(
            host=self.host, port=self.port, db=self.db)

    def publish(self, channel, message):
        self.client.publish(channel, message)

    def pubsub(self):
        return self.client.pubsub()

    def set(self, key, value):
        self.client.set(key, value)

    def expire(self, key, time):
        self.client.expire(key, time)

    def get(self, key):
        return self.client.get(key)
