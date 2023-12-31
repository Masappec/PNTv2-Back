

from app_admin.ports.repositories.access_information_repository import AccessInformationRepository
from django.core.exceptions import ObjectDoesNotExist

class AccessInformationService:
    
    
    def __init__(self, access_information_repository:AccessInformationRepository):
        self.access_information_repository = access_information_repository
        
        
    def create_access_information(self, access_information: dict):
        data = {
            'email': access_information['email_accesstoinformation'],
        }
        return self.access_information_repository.create_access_information(data)
    
        
    def get_access_information(self, access_information_id: int):
        try:
         return self.access_information_repository.get_access_information(access_information_id)
        
        except ObjectDoesNotExist:
            raise ValueError("Información de acceso no existe")
        
        
    def get_all_access_information(self):
        return self.access_information_repository.get_all_access_information()
    
    def get_all_access_information_by_establishment(self, establishment_id: int):
        access =  self.access_information_repository.get_all_access_information_by_establishment(establishment_id)
        if not access:
            raise ValueError("Información de acceso no existe")
        
        
    def update_access_information(self, access_information_id: int, access_information: dict):
        try:
            return self.access_information_repository.update_access_information(access_information_id, access_information)
        except ObjectDoesNotExist:
            raise ValueError("Información de acceso no existe")
        
        
    def delete_access_information(self, access_information_id: int):
        try:
            return self.access_information_repository.delete_access_information(access_information_id)
        except ObjectDoesNotExist:
            raise ValueError("Información de acceso no existe")
        
        
    def assign_establishment_to_access_information(self, access_information_id: int, establishment_id: int):
        try:
            return self.access_information_repository.assign_establishment_to_access_information(access_information_id, establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Información de acceso no existe")
        
        
    def remove_establishment_to_access_information(self, access_information_id: int, establishment_id: int):
        try:
            return self.access_information_repository.remove_establishment_to_access_information(access_information_id, establishment_id)
        except ObjectDoesNotExist:
            raise ValueError("Información de acceso no existe")
        
        
    
    