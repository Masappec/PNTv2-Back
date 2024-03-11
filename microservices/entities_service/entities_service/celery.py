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
    'process_created_transparency_active_entity': {
        'task': 'shared.tasks.ta_task',
        'schedule': crontab(minute=0, hour=0, day_of_month=1),

    },
}
