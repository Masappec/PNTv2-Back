from abc import ABC, abstractmethod



class PublicationRepository(ABC):
    
    @abstractmethod
    def inactivate_publication(self, publication_id: int) -> None:
        pass
    
    
    @abstractmethod
    def get_publication(self, publication_id: int) -> dict:
        pass
    
    
    @abstractmethod
    def get_publications(self) -> dict:
        pass