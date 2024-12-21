from entity_app.ports.repositories.transparency_active import TransparencyActiveRepository
from entity_app.models import TransparencyActive
from django.db.models.query import QuerySet

from entity_app.domain.models.transparency_active import StatusNumeral

class TransparencyActiveImpl(TransparencyActiveRepository):

    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        return TransparencyActive.objects.filter(
            year=year,
            month=month,
            establishment_id=establishment_id,
        ).order_by('numeral__name')

    def get_by_numeral(self, numeral_id: int, month: int, year: int, establishment_id: int):
        #ordenar los archivos por Conjunto de datos, Metadatos, Diccionario
        ta = TransparencyActive.objects.filter(
            numeral_id=numeral_id,
            month=month,
            year=year,
            establishment_id=establishment_id
        ).order_by('numeral__name')

        
        return ta
            

    def get_by_year(self, year: int, establishment_id: int) -> QuerySet[TransparencyActive]:
        return TransparencyActive.objects.filter(
            year=year,
            establishment_id=establishment_id,
            status=StatusNumeral.APROVED
        ).order_by('numeral_id')

    def get_by_year_all(self, year: int, establishment_id: int) -> QuerySet[TransparencyActive]:
        return TransparencyActive.objects.filter(
            year=year,
            establishment_id=establishment_id,
        ).order_by('numeral_id')
    def get_search(self, search: str, establishment_id: int):
        return TransparencyActive.objects.filter(
            establishment_id=establishment_id,
            numeral__description__icontains=search
        )

    def get_by_id(self, id: int):
        return TransparencyActive.objects.get(id=id)

    
    def get_months_by_year(self, year: int, establishment_id: int):
        return TransparencyActive.objects.filter(
            year=year,
            establishment_id=establishment_id,
            status=StatusNumeral.APROVED
        ).values('month').distinct()
        
    def get_all_year_month(self,year:int,mont:int):
        return TransparencyActive.objects.filter(
            year=year,
            month=mont,
            status=StatusNumeral.APROVED
        ).order_by('numeral__name')
        
    