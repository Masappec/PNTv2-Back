import os
from celery import Celery
from django.conf import settings
from celery.signals import worker_init

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "public_api_service.settings")
app = Celery("public_celery")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)


@worker_init.connect
def worker_init(**kwargs):
    from core.thread import Subscriptor
    print("Starting thread")
    thread = Subscriptor()
    thread.run()
