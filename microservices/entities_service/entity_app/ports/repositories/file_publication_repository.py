from abc import ABC, abstractmethod

from django.db.models.query import QuerySet
from entity_app.models import FilePublication


class FilePublicationRepository(ABC):

    @abstractmethod
    def save(self, name, description, file):
        pass

    @abstractmethod
    def update(self, file_publication_id, name, description, file):
        pass

    @abstractmethod
    def get(self, file_publication_id):
        pass

    @abstractmethod
    def get_all(self):
        pass

    @abstractmethod
    def delete(self, file_publication_id):
        pass

    @abstractmethod
    def get_by_user_establishment(self, user_establishment_id, type: str, numeral_id: int) -> QuerySet[FilePublication]:
        pass
