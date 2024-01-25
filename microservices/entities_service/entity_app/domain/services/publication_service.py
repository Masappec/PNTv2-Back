


from entity_app.ports.repositories.publication_repository import PublicationRepository
from django.core.exceptions import ObjectDoesNotExist

from entity_app.domain.models.establishment import UserEstablishmentExtended

class PublicationService:
    
    
    def __init__(self, publication_repository: PublicationRepository):
        self.publication_repository = publication_repository
        
        
    
    def inactivate_activate_publication(self, publication_id: int,user_id):
            
            return self.publication_repository.inactivate_activate_publication(publication_id,user_id)
        
        
    def get_publication(self, publication_id: int):
        
        return self.publication_repository.get_publication(publication_id)
    
    
    def get_publications_transparency_active(self):
            
        return self.publication_repository.get_publications_transparency_active()
    
    def get_publications(self):
         return self.publication_repository.get_publications()
     
    
    
    def get_publications_by_user_id(self, user_id: int):
        try:
            return self.publication_repository.get_publications_by_user_id(user_id)
        
        except ObjectDoesNotExist:
            raise Exception('El usuario no tiene establecimiento')
        
        
    def get_publication_by_slug(self, slug: str):
        try:
            return self.publication_repository.get_publication_by_slug(slug)
        
        except ObjectDoesNotExist:
            raise Exception('La publicacion no existe')
        
    def create_publication(self, publicacion: dict, user_id: int):
        try:
            user_establishment =UserEstablishmentExtended.objects.get(user_id=user_id)
            publicacion['establishment_id'] = user_establishment.establishment.id
            publicacion['user_created_id'] = user_id
            return self.publication_repository.create_publication(publicacion)
        except Exception as e:
            raise e
        
    def update_publication(self, publicacion_id: int, publicacion: dict):
        try:
            return self.publication_repository.update_publication(publicacion_id, publicacion)
        except ObjectDoesNotExist:
            raise ValueError("publicacion no existe")
        
        
    def get_publication_detail_admin(self, publication_id: int,user_id:int):
            
        try:
            return self.publication_repository.get_publication_detail_admin(publication_id,user_id)
        
        except ObjectDoesNotExist:
            raise Exception('La publicacion no existe')