
import json


class CallbackObserver:
    def __init__(self, callback, channel, type):
        self.callback = callback
        self.channel = channel
        self.type = type

    def update(self, message, channel):
        if channel == self.channel:

            dict_ = json.loads(message['data'])
            print(dict_['type'], self.type)
            if self.type == dict_['type']:
                print(f"Recibido mensaje de tipo  {self.type}")
                payload = dict_['payload']

                print(payload)
                self.callback(**payload)
