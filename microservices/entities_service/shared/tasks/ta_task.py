from entities_service.celery import app
from celery import shared_task
from django.core.files.uploadedfile import UploadedFile, TemporaryUploadedFile


@shared_task(bind=True)
def process_updaload_data(self, fileMeta: UploadedFile, fileDataset: UploadedFile, dicctionary: UploadedFile,
                          numeral_id: int, user_id: int):

    pass
