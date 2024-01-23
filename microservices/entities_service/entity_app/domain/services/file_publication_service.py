

from entity_app.ports.repositories.file_publication_repository import FilePublicationRepository
from django.core.exceptions import ObjectDoesNotExist
class FilePublicationService:
    
    def __init__(self, file_repository: FilePublicationRepository):
        self.file_repository = file_repository
        
        
    def save(self, name, description, file):
        return self.file_repository.save(name, description, file)
    
    
    def get(self, file_publication_id):
        return self.file_repository.get(file_publication_id)
    
    
    def get_all(self):
        return self.file_repository.get_all()
    
    def update(self, file_publication_id, name, description, file):
        return self.file_repository.update(file_publication_id, name, description, file)
    
    
    def delete(self, file_publication_id):
        return self.file_repository.delete(file_publication_id)
    
    
    def get_by_user_establishment(self, user_id):
        try:
            return self.file_repository.get_by_user_establishment(user_id)
        except ObjectDoesNotExist:
            raise Exception("Usuario no encontrado")