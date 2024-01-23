from abc import ABC, abstractmethod

class FilePublicationRepository(ABC):
    
    @abstractmethod
    def save(self, name, description, file):
        pass
    
    @abstractmethod
    def update(self, file_publication_id, name, description, file):
        pass

    @abstractmethod
    def get(self, file_publication_id):
        pass

    @abstractmethod
    def get_all(self):
        pass

    @abstractmethod
    def delete(self, file_publication_id):
        pass
    
    @abstractmethod
    def get_by_user_establishment(self, user_establishment_id):
        pass
    
    
 