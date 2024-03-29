from abc import ABC, abstractmethod


class TypeOrganizationRepository(ABC):

    @abstractmethod
    def get_all(self):
        pass
    
    
    @abstractmethod
    def create_type_organization(self, name: str):
        pass
