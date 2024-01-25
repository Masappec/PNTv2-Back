from entity_app.ports.repositories.attachment_repository import AttachmentRepository
from django.core.exceptions import ObjectDoesNotExist
class AttachmentService:
    
    
    def __init__(self, attachment_repository: AttachmentRepository):
        self.attachment_repository = attachment_repository
        
        
    def save(self, attachment):
        return self.attachment_repository.save(attachment)
    
    def get(self, attachment_id):
        return self.attachment_repository.get(attachment_id)
    
    
    def get_by_entity_id(self, entity_id):
        return self.attachment_repository.get_by_entity_id(entity_id)
    
    
    def delete(self, attachment_id):
        return self.attachment_repository.delete(attachment_id)
    
    
    def get_by_user_id(self, user_id):
        try:
            return self.attachment_repository.get_by_user_id(user_id)
        
        except ObjectDoesNotExist:
            raise ObjectDoesNotExist("No se encontraron archivos adjuntos para el usuario")