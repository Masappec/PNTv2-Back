from django_thread import Thread
from app_admin.adapters.messaging.subscribe import create_subscription
from app_admin.adapters.messaging.callback_observer import CallbackObserver
from shared.tasks.user_task import send_user_created_event
from app_admin.adapters.messaging.channels import CHANNEL_USER, CHANNEL_SOLICIY
from app_admin.adapters.messaging.events import USER_CREATED, USER_UPDATED, USER_REGISTER, \
    USER_PASSWORD_RESET_REQUESTED, SOLICITY_CITIZEN_CREATED, SOLICITY_RESPONSE_ESTABLISHMENT, SOLICITY_RESPONSE_USER, SOLICITY_FOR_EXPIRED, SOLICITY_USER_EXPIRED
from shared.tasks.auth_task import auth_send_activate_account_event
from shared.tasks.auth_task import auth_send_password_reset_event
from shared.tasks.solicity_task import send_email_citizen_create_solicity, send_email_establishment_response, send_mail_citizen_response
import os


class Subscriptor:

    def run(self):

        self.build_user_events()
        self.build_solicity_events()

    def build_user_events(self):

        user_callbacks = [
            CallbackObserver(callback=send_user_created_event,
                             channel=CHANNEL_USER, type=USER_CREATED),
            CallbackObserver(callback=send_user_created_event,
                             channel=CHANNEL_USER, type=USER_UPDATED),
            CallbackObserver(callback=auth_send_activate_account_event,
                             channel=CHANNEL_USER, type=USER_REGISTER),
            CallbackObserver(callback=auth_send_password_reset_event,
                             channel=CHANNEL_USER, type=USER_PASSWORD_RESET_REQUESTED)
        ]
        self.start_subscription_thread(CHANNEL_USER, user_callbacks)

    def build_solicity_events(self):

        solicity_callbacks = [
            CallbackObserver(callback=send_email_citizen_create_solicity,
                             channel=CHANNEL_SOLICIY, type=SOLICITY_CITIZEN_CREATED),
            CallbackObserver(callback=send_email_establishment_response,
                             channel=CHANNEL_SOLICIY, type=SOLICITY_RESPONSE_ESTABLISHMENT),
            CallbackObserver(callback=send_mail_citizen_response,
                             channel=CHANNEL_SOLICIY, type=SOLICITY_RESPONSE_USER)
        ]
        self.start_subscription_thread(CHANNEL_SOLICIY, solicity_callbacks)

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
