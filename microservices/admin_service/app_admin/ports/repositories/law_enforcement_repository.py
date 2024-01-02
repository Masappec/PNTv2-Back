
from abc import ABC, abstractmethod


class LawEnforcementRepository(ABC):
    
    @abstractmethod
    def get_law_enforcement(self, law_enforcement_id: int):
        pass
    @abstractmethod
    
    def create_law_enforcement(self, law_enforcement: dict):
        pass
    
    @abstractmethod
    
    def assign_establishment_to_law_enforcement(self, law_enforcement_id: int, establishment_id):
        pass
    @abstractmethod
   
    def remove_establishment_to_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        pass
    @abstractmethod
    
    def update_law_enforcement(self, law_enforcement_id: int, law_enforcement: dict):
        pass
    @abstractmethod
    
    def delete_law_enforcement(self, law_enforcement_id: int):
        pass
    @abstractmethod
    
    def get_all_law_enforcement(self):
        pass
    
    @abstractmethod
    def get_law_enforcement_by_establishment(self, establishment_id: int):
        pass
    
    @abstractmethod
    def update_law_enforcement_by_establishment_id(self, establishment_id: int, law_enforcement: dict):
        pass