from entity_app.ports.repositories.transparency_active import TransparencyActiveRepository
from entity_app.models import TransparencyActive


class TransparencyActiveImpl(TransparencyActiveRepository):

    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        return TransparencyActive.objects.filter(
            year=year,
            month=month,
            establishment_id=establishment_id
        ).order_by('numeral__name')

    def get_by_numeral(self, numeral_id: int, month: int, year: int, establishment_id: int):
        return TransparencyActive.objects.filter(
            numeral_id=numeral_id,
            month=month,
            year=year,
            establishment_id=establishment_id
        ).order_by('numeral__name')

    def get_by_year(self, year: int, establishment_id: int):
        return TransparencyActive.objects.filter(
            year=year,
            establishment_id=establishment_id
        ).order_by('numeral_id')

    def get_search(self, search: str, establishment_id: int):
        return TransparencyActive.objects.filter(
            establishment_id=establishment_id,
            numeral__description__icontains=search
        )

    def get_by_id(self, id: int):
        return TransparencyActive.objects.get(id=id)
