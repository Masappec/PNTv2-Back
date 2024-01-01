import os
from celery import Celery
from celery.signals import task_sent, task_success, task_failure

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "admin_service.settings")
app = Celery("admin_celery")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks(['shared.tasks.user_task', 'shared.tasks.events'])

