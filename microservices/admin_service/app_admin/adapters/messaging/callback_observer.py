
import json


class CallbackObserver:
    def __init__(self, callback, channel, type):
        self.callback = callback
        self.channel = channel
        self.type = type

    def update(self, message, channel):
        if channel == self.channel:

            dict_ = json.loads(message['data'])
            if self.type == dict_['type']:
                print(f"Recibido mensaje de tipo  {self.type}")
                payload = dict_['payload']

                self.callback(**payload)
