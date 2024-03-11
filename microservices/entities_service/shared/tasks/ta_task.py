from entities_service.celery import app
from celery import shared_task
from django.core.files.uploadedfile import UploadedFile, TemporaryUploadedFile
from datetime import datetime

from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entity_app.domain.models.establishment import EstablishmentExtended


@shared_task(bind=True)
def process_updaload_data(self, fileMeta: UploadedFile, fileDataset: UploadedFile, dicctionary: UploadedFile,
                          numeral_id: int, user_id: int):

    pass


@shared_task(bind=True)
def process_created_transparency_active_entity(self):
    print("Process created transparency active entity ")
    month = datetime.now().month
    year = datetime.now().year

    service = NumeralService(
        numeral_repository=NumeralImpl(),
    )

    entities = EstablishmentExtended.objects.all()
    for entity in entities:
        numerals_by_entity = service.get_by_entity(entity.id)
        for numeral in numerals_by_entity:

            ta = service.get_transparency_by_numeral(
                numeral.id, month, year, entity.id)
            if not ta:
                service.create_transparency(
                    entity.id, numeral.id, [], month, year, datetime.now(), "pending")

                print("Transparency Active created ")
