from django_thread import Thread
from core.adapters.messaging.subscribe import create_subscription
from core.adapters.messaging.callback_observer import CallbackObserver
from core.adapters.messaging.channels import CHANNEL_ESTABLISHMENT_NUMERAL
from core.adapters.messaging.events import TRANSPARENCY_ACTIVE_UPLOAD
from core.tasks.ta_tasks import on_update_ta


class Subscriptor:

    def run(self):
        print("Starting thread ")
        self.build_user_events()

    def build_user_events(self):

        user_callbacks = [
            CallbackObserver(callback=on_update_ta,
                             channel=CHANNEL_ESTABLISHMENT_NUMERAL, type=TRANSPARENCY_ACTIVE_UPLOAD)
        ]
        self.start_subscription_thread(
            CHANNEL_ESTABLISHMENT_NUMERAL, user_callbacks)

    def start_subscription_thread(self, channel, callbacks):

        subscribe_channel = SubscribeChannel(channel, callbacks)
        subscribe_channel.start()


class SubscribeChannel(Thread):

    def __init__(self, channel, observers):
        super().__init__()
        self.channel = channel
        self.observers = observers

    def run(self):
        create_subscription(self.channel, self.observers)
