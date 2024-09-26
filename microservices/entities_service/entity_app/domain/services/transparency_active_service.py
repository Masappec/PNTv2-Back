
from entity_app.ports.repositories.transparency_active import TransparencyActiveRepository
from django.db.models.query import QuerySet
from entity_app.models import TransparencyActive


class TransparencyActiveService:

    def __init__(self, respository: TransparencyActiveRepository):
        self.repository = respository

    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        return self.repository.get_by_year_month(year, month, establishment_id)

    def get_by_numeral(self, numeral_id: int, month: int, year: int, establishment_id: int):
        return self.repository.get_by_numeral(numeral_id, month, year, establishment_id)

    def get_by_year(self, year: int, establishment_id: int) -> QuerySet[TransparencyActive]:
        return self.repository.get_by_year(year, establishment_id)

    def get_search(self, search: str, establishment_id: int):
        return self.repository.get_search(search, establishment_id)

    def get_by_id(self, id: int):
        return self.repository.get_by_id(id)

    def get_months_by_year(self, year: int, establishment_id: int):
        return self.repository.get_months_by_year(year, establishment_id)

    def get_all_year_month(self, year: int, mont: int):
        return self.repository.get_all_year_month(year, mont)
