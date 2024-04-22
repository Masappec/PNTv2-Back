import shared.tasks.events
import os
from celery import Celery
from django.conf import settings
from celery.signals import worker_init

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "admin_service.settings")
app = Celery("admin_celery")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)


@worker_init.connect
def worker_init(**kwargs):
    from app_admin.thread import Subscriptor

    thread = Subscriptor()
    thread.run()
