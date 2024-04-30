from entity_app.adapters.messaging.callback_observer import CallbackObserver
from entity_app.adapters.messaging.subscribe import create_subscription
from shared.tasks.establishment_task import establishment_created_event
from entity_app.adapters.messaging.events import ESTABLISHMENT_CREATED, ESTABLISHMENT_UPDATED
from entity_app.adapters.messaging.channels import CHANNEL_ESTABLISHMENT
from django_thread import Thread


class Subscriptor:

    def run(self):

        self.build_establishment_events()

    def build_establishment_events(self):

        establistmen_created_observer = CallbackObserver(
            establishment_created_event, CHANNEL_ESTABLISHMENT, ESTABLISHMENT_CREATED)

        establishment_update_observer = CallbackObserver(
            establishment_created_event, CHANNEL_ESTABLISHMENT, ESTABLISHMENT_UPDATED)

        observers = [establistmen_created_observer,
                     establishment_update_observer]
        self.start_subscription_thread(CHANNEL_ESTABLISHMENT, observers)

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
