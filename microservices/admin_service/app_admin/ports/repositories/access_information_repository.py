from abc import ABC, abstractmethod

class AccessInformationRepository(ABC):
    
    
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
    def update_access_information_by_establishment_id(self, establishment_id: int, access_information: dict):
        pass
    
    
    