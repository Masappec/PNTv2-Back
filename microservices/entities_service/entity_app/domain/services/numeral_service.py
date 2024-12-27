##
from typing import List
from entity_app.ports.repositories.numeral_repository import NumeralRepository
from entity_app.domain.models.transparency_active import Numeral
from django.db.models.query import QuerySet


class NumeralService:

    def __init__(self, numeral_repository: NumeralRepository):
        self.numeral_repository = numeral_repository

    def get_by_entity(self, entity_id) -> QuerySet[Numeral]:
        return self.numeral_repository.get_by_entity(entity_id)

    def get(self, id):
        return self.numeral_repository.get(id)

    def get_all_transparency(self):
        return self.numeral_repository.get_all_transparency()

    def filter_by_list_ids(self, ids):
        return self.numeral_repository.filter_by_list_ids(ids)

    def asign_numeral_to_establishment(self, ids: List[Numeral], establishment_id: int):
        return self.numeral_repository.asign_numeral_to_establishment(ids, establishment_id)

    def get_by_default(self, default: bool):
        return self.numeral_repository.get_by_default(default)

    def get_transparency_by_numeral(self, numeral, month, year, establishment_id):
        return self.numeral_repository.get_transparency_by_numeral(numeral, month, year, establishment_id)

    def create_transparency(self, establishment_id, numeral_id, files, month, year, fecha_actual, status="ingress"):
        return self.numeral_repository.create_transparency(establishment_id, numeral_id, files, month, year, fecha_actual, status)

    def get_all(self) -> List[Numeral]:
        return self.numeral_repository.get_all()

    def get_numeral_focalized_or_collab(self, type: str):
        return self.numeral_repository.get_numeral_focalized_or_collab(type)

    def aprove_transparency(self, id):
        return self.numeral_repository.aprove_transparency(id)

    def update_numeral_state(self, numeral_id: int, is_selected: bool):
        numeral = self.numeral_repository.get_by_id(numeral_id)
        if not numeral:
            raise ValueError(f"El numeral con ID {numeral_id} no existe.")

        numeral.is_selected = is_selected
        updated_numeral = self.numeral_repository.update(numeral)
        return updated_numeral

