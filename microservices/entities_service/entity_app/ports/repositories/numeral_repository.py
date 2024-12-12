##
from abc import ABC, abstractmethod
from typing import List
from entity_app.domain.models.transparency_active import Numeral
from django.db.models.query import QuerySet


class NumeralRepository(ABC):

    def get_all(self):
        pass

    def get(self, id):
        pass

    def get_by_entity(self, entity_id):
        pass

    def get_all_transparency(self):
        pass

    def filter_by_list_ids(self, ids: List[int]) -> QuerySet[Numeral]:
        pass

    def asign_numeral_to_establishment(self, ids_numeral: List[int], establishment_id: int):

        pass

    def get_by_default(self, default: bool) -> QuerySet[Numeral]:

        pass

    def get_transparency_by_numeral(self, numeral, month, year, establishment_id):
        pass

    def create_transparency(self, establishment_id, numeral_id, files, month, year, fecha_actual, get_transparency_by_numeral, status="ingress"):
        pass

    def get_numeral_focalized_or_collab(self, type: str):
        pass

    def update_transparency(self, establishment_id, numeral_id, files, month, year, fecha_actual, status="ingress"):
        pass

    def aprove_transparency(self, id):

        pass

    def get_by_id(self, numeral_id: int):
        """
        Obtener un numeral por su ID.
        """
        pass

    def update(self, numeral: Numeral):
        """
        Actualizar un numeral en la base de datos.
        """
        pass
