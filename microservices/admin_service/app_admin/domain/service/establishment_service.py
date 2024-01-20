

from app_admin.ports.repositories.establishment_repository import EstablishmentRepository
from django.core.exceptions import ObjectDoesNotExist

class EstablishmentService:
    def __init__(self, establishment_repository: EstablishmentRepository):
        self.establishment_repository = establishment_repository

    def create_establishment(self, establishment: dict, file):
        try:
            
            
            return self.establishment_repository.create_establishment(establishment, file)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        except Exception as e:
            raise e
    
    def get_establishment(self, establishment_id: int):
        return self.establishment_repository.get_establishment(establishment_id)
    
    def get_public_establishment(self):
        return self.establishment_repository.get_public_establishment()
    
    def get_establishments(self):
        return self.establishment_repository.get_all_establishments()
    
    def update_establishment(self, establishment_id: int, establishment: dict):
        try:
            return self.establishment_repository.update_establishment(establishment_id, establishment)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
    def delete_establishment(self, establishment_id: int):
        try:
            return self.establishment_repository.delete_establishment(establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
    def get_establishment_by_name(self, name: str):
        es = self.establishment_repository.get_establishment_by_name(name)
        if not es:
            raise ValueError("Instiución no existe")
    
    def get_establishment_by_abbreviation(self, abbreviation: str):
        es = self.establishment_repository.get_establishment_by_abbreviation(abbreviation)
        if not es:
            raise ValueError("Instiución no existe")
        
        
    def assign_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        try:
            return self.establishment_repository.assign_law_enforcement(law_enforcement_id, establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
    def assign_access_to_information(self, access_to_information_id: int, establishment_id: int):
        try:
            return self.establishment_repository.assign_access_to_information(access_to_information_id, establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
    def remove_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        try:
            return self.establishment_repository.remove_law_enforcement(law_enforcement_id, establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
    def remove_access_to_information(self, access_to_information_id: int, establishment_id: int):
        try:
            return self.establishment_repository.remove_access_to_information(access_to_information_id, establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
        
    def get_first_access_to_information(self, establishment_id: int):
        try:
            return self.establishment_repository.get_first_access_to_information(establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
    def get_first_law_enforcement(self, establishment_id: int):
        try:
            return self.establishment_repository.get_first_law_enforcement(establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
    def update_logo(self, establishment_id: int, file):
        try:
            return self.establishment_repository.update_logo(establishment_id, file)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")
        
    def activa_or_deactivate_establishment(self, establishment_id: int):
        try:
            return self.establishment_repository.activa_or_deactivate_establishment(establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Instiución no existe")