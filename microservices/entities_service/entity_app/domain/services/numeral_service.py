
from entity_app.ports.repositories.numeral_repository import NumeralRepository
class NumeralService:
    
    
    def __init__(self, numeral_repository: NumeralRepository):
        self.numeral_repository = numeral_repository
        
        
    
    def get_by_entity(self, entity_id):
        return self.numeral_repository.get_by_entity(entity_id)
    
    
    
    def get(self, id):
        return self.numeral_repository.get(id)