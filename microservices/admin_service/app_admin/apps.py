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
        from app_admin.adapters.messaging.channels import CHANNEL_USER, CHANNEL_SOLICIY
        from app_admin.adapters.messaging.events import USER_CREATED, USER_UPDATED, USER_REGISTER, \
            USER_PASSWORD_RESET_REQUESTED, SOLICITY_CITIZEN_CREATED, SOLICITY_RESPONSE_ESTABLISHMENT, SOLICITY_RESPONSE_USER, SOLICITY_FOR_EXPIRED, SOLICITY_USER_EXPIRED
        from shared.tasks.auth_task import auth_send_activate_account_event
        from shared.tasks.auth_task import auth_send_password_reset_event
        from shared.tasks.solicity_task import send_email_citizen_create_solicity, send_email_establishment_response, send_mail_citizen_response
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

        callbacks_solicity = []
        citizen_create_solicity = CallbackObserver(
            callback=send_email_citizen_create_solicity, channel=CHANNEL_SOLICIY, type=SOLICITY_CITIZEN_CREATED)
        establishment_response = CallbackObserver(
            callback=send_email_establishment_response, channel=CHANNEL_SOLICIY, type=SOLICITY_RESPONSE_ESTABLISHMENT)
        user_response = CallbackObserver(
            callback=send_mail_citizen_response, channel=CHANNEL_SOLICIY, type=SOLICITY_RESPONSE_USER)

        callbacks_solicity.append(citizen_create_solicity)
        callbacks_solicity.append(establishment_response)
        callbacks_solicity.append(user_response)

        subscribe_thread_solicity = Thread(
            target=create_subscription, args=(CHANNEL_SOLICIY, callbacks_solicity,))

        subscribe_thread_solicity.daemon = True
        subscribe_thread_solicity.start()
