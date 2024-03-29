from django.apps import AppConfig
from app_admin.adapters.messaging.subscribe import subscribe_channel


class AppAdmin(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'app_admin'

    def ready(self) -> None:
        channel = 'user'
        print("Escuchando canal: ", channel)
        # subscribe_channel(channel)
