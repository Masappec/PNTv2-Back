


from entity_app.ports.repositories.attachment_repository import AttachmentRepository
from entity_app.domain.models.publication import Attachment
from entity_app.domain.models.establishment import UserEstablishmentExtended
from django.contrib.auth.models import User

class AttachmentImpl(AttachmentRepository):
    
    def save(self, attachment):
        return Attachment.objects.create(**attachment)
    
    
    def get(self, attachment_id):
        return Attachment.objects.get(id=attachment_id)
    
    
    def get_by_entity_id(self, entity_id):
        return Attachment.objects.filter(publication_set__entity_id=entity_id)
    
    def delete(self, attachment_id):
        return Attachment.objects.get(id=attachment_id).delete()
    
    def get_by_user_id(self, user_id):
        
        user_obj = User.objects.get(id=user_id)
        if user_obj.is_superuser:
            return Attachment.objects.all()
        
        user = UserEstablishmentExtended.objects.get(user_id=user_id)
    
        return Attachment.objects.filter(publication_set__entity_id=user.establishment.id)