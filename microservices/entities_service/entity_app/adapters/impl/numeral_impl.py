

from typing import List

from django.db.models.query import QuerySet
from entity_app.ports.repositories.numeral_repository import NumeralRepository
from entity_app.domain.models.transparency_active import Numeral, EstablishmentNumeral, TransparencyActive
from django.db.models import Value, IntegerField
from django.db.models.functions import Cast


class NumeralImpl(NumeralRepository):

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

        for numeral in ids_numeral:

            EstablishmentNumeral.objects.create(
                establishment_id=establishment_id,
                numeral=numeral,
                value='default'
            )

    def get_by_default(self, default: bool) -> QuerySet[Numeral]:
        return Numeral.objects.filter(is_default=default, type_transparency='A').order_by('name')

    def get_transparency_by_numeral(self, numeral, month, year, establishment_id):
        return TransparencyActive.objects.filter(numeral=numeral, month=month, year=year, establishment_id=establishment_id).first()

    def create_transparency(self, establishment_id, numeral_id, files, month, year, fecha_actual, status="ingress"):
        obj = TransparencyActive.objects.create(
            establishment_id=establishment_id,
            numeral_id=numeral_id,
            month=month,
            year=year,
            status=status,
            published=status == "ingress",
            published_at=fecha_actual if status == "ingress" else None

        )
        obj.files.set(files)
        return obj

    def get_numeral_focalized_or_collab(self, type: str):
        return Numeral.objects.filter(type_transparency=type).first()
