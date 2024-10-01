from abc import ABC, abstractmethod

from app_admin.domain.models import Establishment


class EstablishmentRepository(ABC):

    @abstractmethod
    def get_establishment(self, establishment_id: int):
        pass

    @abstractmethod
    def get_public_establishment(self):
        pass

    @abstractmethod
    def get_establishment_by_abbr(self, abbreviation: str):
        pass

    @abstractmethod
    def get_establishment_by_abbreviation(self, abbreviation: str):
        pass

    @abstractmethod
    def get_establishment_by_name(self, name: str):
        pass

    @abstractmethod
    def get_first_law_enforcement(self, establishment_id: int):
        pass

    @abstractmethod
    def get_first_access_to_information(self, establishment_id: int):
        pass

    @abstractmethod
    def get_first_law_enforcement_by_establishment(self, establishment_id: int):
        pass

    @abstractmethod
    def create_establishment(self, establishment: dict, file) -> Establishment:
        pass

    @abstractmethod
    def assign_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        pass

    @abstractmethod
    def assign_access_to_information(self, access_to_information_id: int, establishment_id: int):
        pass

    @abstractmethod
    def update_establishment(self, establishment_id: int, establishment: dict) -> Establishment:
        pass

    @abstractmethod
    def delete_establishment(self, establishment_id: int):
        pass

    @abstractmethod
    def get_all_establishments(self):
        pass

    @abstractmethod
    def remove_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        pass

    @abstractmethod
    def remove_access_to_information(self, access_to_information_id: int, establishment_id: int):
        pass

    @abstractmethod
    def remove_all_law_enforcement(self, establishment_id: int):
        pass

    @abstractmethod
    def remove_all_access_to_information(self, establishment_id: int):
        pass

    @abstractmethod
    def update_logo(self, establishment_id: int, file):
        pass

    def activa_or_deactivate_establishment(self, establishment_id: int):
        pass

    @abstractmethod
    def get_establishment_by_slug(self, slug: str):
        pass

    @abstractmethod
    def get_establishment_by_user_id(self, user_id) -> Establishment:
        pass

    @abstractmethod
    def get_users_by_establishment(self, establishment_id: int):
        pass

        
    @abstractmethod
    def get_by_identification(self,ruc:str):
        pass