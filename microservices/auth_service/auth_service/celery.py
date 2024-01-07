import os
from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "auth_service.settings")
app = Celery("auth_celery")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks(['shared.tasks.user_task','shared.tasks.auth_task'])