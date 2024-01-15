from django.apps import AppConfig
from celery.signals import after_setup_task_logger


class SharedConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'shared'

    
    def ready(self):
        after_setup_task_logger.connect(self.on_celery_setup)

    def on_celery_setup(self, **kwargs):
        # Este método se llamará después de que Celery haya configurado su registrador de tareas
        from shared.tasks.emit import ping_task
        ping_task.delay()