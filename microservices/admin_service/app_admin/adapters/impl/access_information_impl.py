

from app_admin.domain.models import AccessToInformation
from app_admin.ports.repositories.access_information_repository import AccessInformationRepository


class AccessInformationImpl(AccessInformationRepository):
    
    
    '''    
    @abstractmethod
    def get_access_information(self, access_information_id: int):
        pass
    
    @abstractmethod
    def create_access_information(self, access_information: dict):
        pass
    @abstractmethod
    def update_access_information(self, access_information_id: int, access_information: dict):
        pass
    @abstractmethod
    def delete_access_information(self, access_information_id: int):
        pass
    @abstractmethod
    def get_all_access_information(self):
        pass
    @abstractmethod
    def get_all_access_information_by_establishment(self, establishment_id: int):
        pass
    @abstractmethod
    def assign_establishment_to_access_information(self, access_information_id: int, establishment_id: int):
        pass
    @abstractmethod
    def remove_establishment_to_access_information(self, access_information_id: int, establishment_id: int):
        pass
    @abstractmethod
    def get_all_access_information_by_establishment_and_pedagogy_area(self, establishment_id: int, pedagogy_area_id: int):
        pass'''
        
    def get_access_information(self, access_information_id: int):
        return AccessToInformation.objects.get(pk=access_information_id)
    
    
    def create_access_information(self, access_information: dict):
        return AccessToInformation.objects.create(**access_information)
    
    
    def update_access_information(self, access_information_id: int, access_information: dict):
        access =  AccessToInformation.objects.filter(pk=access_information_id)
        access.update(**access_information)
        
        
    def delete_access_information(self, access_information_id: int):
        AccessToInformation.objects.filter(pk=access_information_id).update(is_active=False)
        
    def get_all_access_information(self):
        return AccessToInformation.objects.filter(is_active=True)
    
    
    def get_all_access_information_by_establishment(self, establishment_id: int):
        return AccessToInformation.objects.filter(is_active=True, establishment_id=establishment_id)
    
    
    def assign_establishment_to_access_information(self, access_information_id: int, establishment_id: int):
        access = AccessToInformation.objects.get(pk=access_information_id)
        access.establishment_id = establishment_id
        access.save()
        
    def remove_establishment_to_access_information(self, access_information_id: int, establishment_id: int):
        access = AccessToInformation.objects.get(pk=access_information_id)
        access.is_active = False
        access.save()
        

    
        
    
    
    