from django.apps import AppConfig

from threading import Thread


class EntityAppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'entity_app'

    def ready(self) -> None:
        self.build_entity_observer()

    def build_entity_observer(self):
        from entity_app.adapters.messaging.callback_observer import CallbackObserver
        from entity_app.adapters.messaging.subscribe import create_subscription
        from shared.tasks.establishment_task import establishment_created_event
        from entity_app.adapters.messaging.events import ESTABLISHMENT_CREATED, ESTABLISHMENT_UPDATED
        from entity_app.adapters.messaging.channels import CHANNEL_ESTABLISHMENT
        establistmen_created_observer = CallbackObserver(
            establishment_created_event, CHANNEL_ESTABLISHMENT, ESTABLISHMENT_CREATED)

        establishment_update_observer = CallbackObserver(
            establishment_created_event, CHANNEL_ESTABLISHMENT, ESTABLISHMENT_UPDATED)

        observers = [establistmen_created_observer,
                     establishment_update_observer]
        print("Creando observadores ")
        subscribe_thread = Thread(
            target=create_subscription, args=(CHANNEL_ESTABLISHMENT, observers,))
        # Establece el hilo como demonio para que se detenga cuando la aplicación se cierre
        subscribe_thread.daemon = True
        subscribe_thread.start()
