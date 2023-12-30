from abc import ABC, abstractmethod


class EstablishmentRepository(ABC):
    
    
    @abstractmethod
    def get_establishment(self, establishment_id: int):
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
    def create_establishment(self, establishment: dict):
        pass
    
    
    @abstractmethod
    def assign_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        pass
    
    @abstractmethod
    def assign_access_to_information(self, access_to_information_id: int, establishment_id: int):
        pass
    
    @abstractmethod
    def update_establishment(self, establishment_id: int, establishment: dict):
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
    
    
    
    
