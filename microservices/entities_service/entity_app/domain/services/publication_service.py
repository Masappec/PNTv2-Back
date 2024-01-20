


from entity_app.ports.repositories.publication_repository import PublicationRepository


class PublicationService:
    
    
    def __init__(self, publication_repository: PublicationRepository):
        self.publication_repository = publication_repository
        
        
    
    def inactivate_publication(self, publication_id: int):
            
            return self.publication_repository.inactivate_publication(publication_id)
        
        
    def get_publication(self, publication_id: int):
        
        return self.publication_repository.get_publication(publication_id)
    
    
    def get_publications(self):
            
        return self.publication_repository.get_publications()