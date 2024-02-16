


from entity_app.ports.repositories.numeral_repository import NumeralRepository
from entity_app.domain.models.transparency_active import Numeral, EstablishmentNumeral

class NumeralImpl(NumeralRepository):
    
    
    
    def get_all(self):
        return Numeral.objects.all()
    

    
    
    def get(self, id):
        numeral = Numeral.objects.get(id=id)
        return numeral
    
    
    def get_by_entity(self, entity_id):
        ids = EstablishmentNumeral.objects.filter(establishment_id=entity_id).values('numeral_id')
        
        return Numeral.objects.filter(id__in=ids)
    
    
    