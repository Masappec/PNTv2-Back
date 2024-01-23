from abc import ABC, abstractmethod



class PublicationRepository(ABC):
    
    @abstractmethod
    def inactivate_publication(self, publication_id: int) -> None:
        pass
    
    
    @abstractmethod
    def get_publication(self, publication_id: int) -> dict:
        pass
    
    
    @abstractmethod
    def get_publications_transparency_active(self) -> dict:
        pass

    @abstractmethod
    def get_publications(self) -> dict:
        pass
    
    
    @abstractmethod
    def get_publications_by_user_id(self, user_id: int) -> dict:
        pass
    
    @abstractmethod
    def get_publication_by_slug(self, slug: str) -> dict:
        pass

    @abstractmethod
    def create_publication(self, publicacion: dict):
        pass

    @abstractmethod
    def update_publication(self, publicacion: dict):
        pass