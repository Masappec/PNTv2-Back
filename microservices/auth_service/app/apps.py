from django.apps import AppConfig
from django.db.models.signals import post_migrate
from django.db import DEFAULT_DB_ALIAS


class AppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'app'

    def ready(self):
        post_migrate.connect(
            self.create_custom_permissions_handler, sender=self)
        # import app.ports.signals.password_reset_token_created
        # from app.utils.config import create_custom_permissions

        # create_custom_permissions()

    def create_custom_permissions_handler(self, **kwargs):
        # Verifica si la señal post_migrate es para la base de datos predeterminada
        if kwargs.get('using', DEFAULT_DB_ALIAS) != DEFAULT_DB_ALIAS:
            return

        from app.utils.config import create_custom_permissions
        create_custom_permissions()
