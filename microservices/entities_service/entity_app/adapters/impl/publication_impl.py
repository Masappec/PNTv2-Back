from entity_app.ports.repositories.publication_repository import PublicationRepository
from entity_app.domain.models import Publication

class PublicationImpl(PublicationRepository):
    
    def inactivate_publication(self, publication_id: int):
        
       return Publication.objects.filter(id=publication_id).update(is_active=False)
        
        
    def get_publication(self, publication_id: int):
        
        publication = Publication.objects.get(id=publication_id)
        
        return publication.to_dict()
    
    
    def get_publications_transparency_active(self):
        
        publications = Publication.objects.filter(is_active=True).filter(type_publication__code='TA')
        
        return publications
    
    def get_publications(self):
        publications = Publication.objects.all()