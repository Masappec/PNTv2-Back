from django.apps import AppConfig
from app_admin.adapters.messaging.subscribe import create_subscription
from threading import Thread


class AppAdmin(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'app_admin'

    def ready(self) -> None:
        self.build_user_events()

    def build_user_events(self):
        from app_admin.adapters.messaging.callback_observer import CallbackObserver
        from shared.tasks.user_task import send_user_created_event
        from app_admin.adapters.messaging.channels import CHANNEL_USER
        from app_admin.adapters.messaging.events import USER_CREATED, USER_UPDATED, USER_REGISTER, \
            USER_PASSWORD_RESET_REQUESTED
        from shared.tasks.auth_task import auth_send_activate_account_event
        from shared.tasks.auth_task import auth_send_password_reset_event
        callbacks = []

        user_create_observer = CallbackObserver(
            callback=send_user_created_event, channel=CHANNEL_USER, type=USER_CREATED)

        user_update_observer = CallbackObserver(
            callback=send_user_created_event, channel=CHANNEL_USER, type=USER_UPDATED)

        auth_register = CallbackObserver(
            callback=auth_send_activate_account_event, channel=CHANNEL_USER, type=USER_REGISTER)

        auth_password_reset = CallbackObserver(
            callback=auth_send_password_reset_event, channel=CHANNEL_USER, type=USER_PASSWORD_RESET_REQUESTED)

        callbacks.append(user_update_observer)
        callbacks.append(user_create_observer)
        callbacks.append(auth_register)
        callbacks.append(auth_password_reset)

        subscribe_thread = Thread(
            target=create_subscription, args=(CHANNEL_USER, callbacks,))
        # Establece el hilo como demonio para que se detenga cuando la aplicación se cierre
        subscribe_thread.daemon = True
        subscribe_thread.start()
