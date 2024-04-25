import os
from celery import Celery
from django.conf import settings
from celery.schedules import crontab

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "entities_service.settings")
app = Celery("entities_celery")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)

app.conf.beat_schedule = {
    # Executes every first day of the month at 00:00
    'add-every-30-seconds': {
        # 'task': 'shared.tasks.ta_task',
        'task': 'shared.tasks.emit.ping_task',
        'schedule': 30.0
    },
    'change_status_solicity': {
        'task': 'shared.tasks.solicity_process.change_status_solicity',
        # 30 seconds
        'schedule': 30.0
    },
}
app.conf.timezone = 'UTC'
