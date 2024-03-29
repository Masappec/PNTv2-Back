
from abc import ABC, abstractmethod


class TypeInstutionRepository(ABC):

    @abstractmethod
    def get_all(self):
        pass
    
    
    @abstractmethod
    def create_type_institution(self, name: str):
        pass
