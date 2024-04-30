from django.apps import AppConfig

from threading import Thread


class EntityAppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'entity_app'
