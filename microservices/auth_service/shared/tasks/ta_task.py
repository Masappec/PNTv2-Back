from celery import shared_task


@shared_task(bind=True)
def process_created_transparency_active_entity(self):
    pass
