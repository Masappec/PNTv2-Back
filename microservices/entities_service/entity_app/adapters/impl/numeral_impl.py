##

from typing import List

from django.db.models.query import QuerySet
from django.db import connection
from entity_app.ports.repositories.numeral_repository import NumeralRepository
from entity_app.domain.models.transparency_active import Numeral, EstablishmentNumeral, StatusNumeral, TransparencyActive
from entity_app.domain.models.publication import FilePublication
from django.db.models import Value, IntegerField
from django.db.models.functions import Cast

from entity_app.adapters.messaging.publish import Publisher
from entity_app.adapters.messaging.channels import CHANNEL_ESTABLISHMENT_NUMERAL
from entity_app.adapters.messaging.events import TRANSPARENCY_ACTIVE_UPLOAD
from datetime import datetime

from entity_app.utils.functions import get_day_for_publish


class NumeralImpl(NumeralRepository):

    def __init__(self) -> None:
        self.publisher = Publisher(CHANNEL_ESTABLISHMENT_NUMERAL)

    def get_all(self):
        return Numeral.objects.all()

    def get(self, id):
        numeral = Numeral.objects.get(id=id)
        return numeral

    def get_by_entity(self, entity_id):
        numerals_ids = EstablishmentNumeral.objects.filter(
            establishment_id=entity_id,
            numeral__type_transparency='A'
        ).values('numeral')

        return Numeral.objects.filter(id__in=numerals_ids).annotate(
            numeral_id_int=Cast('id', IntegerField())
        ).order_by('name')

    def get_all_transparency(self):
        return TransparencyActive.objects.get()

    def filter_by_list_ids(self, ids: List[int]):
        return Numeral.objects.filter(id__in=ids)

    def asign_numeral_to_establishment(self, ids_numeral: List[Numeral], establishment_id: int):
        numerals = self.get_by_entity(establishment_id)

        for numeral in ids_numeral:

            if not numerals.filter(id=numeral.id).exists():

                EstablishmentNumeral.objects.create(
                    establishment_id=establishment_id,
                    numeral=numeral,
                    value='default'
                )

    def get_by_default(self, default: bool) -> QuerySet[Numeral]:
        queryset = Numeral.objects.filter(
            is_default=default,
            #is_selected=False,  # Excluye numerales seleccionados
            type_transparency='A' 
        ).order_by('name')
        return queryset

    def get_transparency_by_numeral(self, numeral, month, year, establishment_id):
        return TransparencyActive.objects.filter(numeral=numeral, month=month, year=year, establishment_id=establishment_id).first()

    def create_transparency(self, establishment_id, numeral_id, files, month, year, fecha_actual, status="ingress"):
        obj = TransparencyActive.objects.create(
            establishment_id=establishment_id,
            numeral_id=numeral_id,
            month=month,
            year=year,
            status=StatusNumeral.INGRESS,
            published=False,
            published_at=None,
            max_date_to_publish=datetime(
            year=year, month=month, day=get_day_for_publish()),
            created_at=fecha_actual


        )
        obj.files.set(files)

        # mover de ubicacion los archivos seleccionados
        list_files = FilePublication.objects.filter(
            id__in=files)
        for file in list_files:
            root = 'transparencia/' + \
                str(obj.establishment.identification) + '/' + \
                str(obj.numeral.name) + '/' + \
                str(obj.year) + '/' + str(obj.month)
            FilePublication.move_file(file, root)
        # filepaths, date, month, year, user, establishment_identification

        self.publisher.publish({
            'type': TRANSPARENCY_ACTIVE_UPLOAD,
            'payload': {
                'filepaths': [file.url_download.path for file in list_files.filter(
                    description='Conjunto de datos')],
                'date': fecha_actual.strftime('%Y-%m-%d'),
                'month': month,
                'year': year,
                'user': establishment_id,
                'establishment_identification': obj.establishment.identification,
                'numeral': obj.numeral.name,
                'establishment_name': obj.establishment.name,
                'numeral_description': obj.numeral.description

            }
        })

        return obj

    def aprove_transparency(self, id):
        obj = TransparencyActive.objects.get(id=id)
        obj.status = StatusNumeral.APROVED
        obj.published = True
        obj.published_at = datetime.now()
        obj.updated_at = datetime.now()
        obj.save()
        return obj

    def get_numeral_focalized_or_collab(self, type: str):
        return Numeral.objects.filter(type_transparency=type).first()

    def get_by_id(self, numeral_id: int):
        """
        Obtener un numeral por su ID.
        """
        return Numeral.objects.filter(id=numeral_id).first()

    
    def get_by_id(self, numeral_id: int):
        # Implementación para obtener un numeral por su ID
        return Numeral.objects.get(id=numeral_id)  # Ejemplo: usando ORM de Django

    def update(self, numeral: Numeral):
        """
        Actualizar un numeral en la base de datos.
        """
        numeral.save()
        return numeral
    
    def exists(self, numeral_id, establishment_id):
        # Verifica si un numeral existe para el establishment
        return EstablishmentNumeral.objects.filter(
            numeral_id=numeral_id,
            establishment_id=establishment_id
        ).exists()
    
    def delete_numeral(self, numeral_id, establishment_id):
        # Eliminar el registro correspondiente en EstablishmentNumeral
        try:
            establishment_numeral = EstablishmentNumeral.objects.get(numeral_id=numeral_id, establishment_id=establishment_id)
            establishment_numeral.delete()  # Esto elimina el objeto de la base de datos
            return establishment_numeral  # Retorna el objeto eliminado, si es necesario
        except EstablishmentNumeral.DoesNotExist:
            raise ValueError("El numeral no existe en el establecimiento.")
        