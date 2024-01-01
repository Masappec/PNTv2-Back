from django.apps import AppConfig


class AppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'app'

    
    def ready(self):
        from app.utils.config import create_custom_permissions
        create_custom_permissions()