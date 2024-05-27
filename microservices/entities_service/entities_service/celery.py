import os
from celery import Celery
from django.conf import settings
from celery.schedules import crontab
from celery.signals import worker_init

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "entities_service.settings")
app = Celery("entities_celery")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)

app.conf.beat_schedule = {

    'change_status_solicity': {
        'task': 'shared.tasks.solicity_process.change_status_solicity',
        'schedule': crontab(minute='0', hour='0')
        # 'schedule': 30.0,
    },
}
app.conf.timezone = 'UTC'


@worker_init.connect
def worker_init(**kwargs):
    from entity_app.thread import Subscriptor

    thread = Subscriptor()
    thread.run()
