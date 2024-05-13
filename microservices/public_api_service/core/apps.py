from django.apps import AppConfig
from celery.signals import after_setup_task_logger


class CoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'core'

    def ready(self):
        print("READY")
        after_setup_task_logger.connect(self.on_celery_setup)

    def on_celery_setup(self, **kwargs):
        # Este método se llamará después de que Celery haya configurado su registrador de tareas
        from core.tasks.emit import ping_task
        ping_task.delay()
