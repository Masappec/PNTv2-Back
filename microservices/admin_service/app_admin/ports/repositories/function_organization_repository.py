from abc import ABC, abstractmethod


class FunctionOrganizationRepository(ABC):

    @abstractmethod
    def get_all(self):
        pass

        
    @abstractmethod
    def create_function_organization(self, name: str):
        pass