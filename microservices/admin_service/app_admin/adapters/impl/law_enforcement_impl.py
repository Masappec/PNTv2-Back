
from django.shortcuts import get_object_or_404
from app_admin.ports.repositories.law_enforcement_repository import LawEnforcementRepository
from app_admin.domain.models import LawEnforcement, Establishment

class LawEnforcementImpl(LawEnforcementRepository):
  
    def get_law_enforcement(self, law_enforcement_id: int):
        return LawEnforcement.objects.get(pk=law_enforcement_id)
    
    def create_law_enforcement(self, law_enforcement: dict):
        return LawEnforcement.objects.create(**law_enforcement)
    
    def assign_establishment_to_law_enforcement(self, law_enforcement_id: int, establishment: Establishment):
        law = LawEnforcement.objects.get(pk=law_enforcement_id)
        law.establishment.add(establishment)
        law.save()
        
    def remove_establishment_to_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        
        law = LawEnforcement.objects.get(pk=law_enforcement_id)
        law.is_active = False
        law.save()
        
    def update_law_enforcement(self, law_enforcement_id: int, law_enforcement: dict):
        law = LawEnforcement.objects.filter(pk=law_enforcement_id)
        law.update(**law_enforcement)
        
    def delete_law_enforcement(self, law_enforcement_id: int):
        LawEnforcement.objects.filter(pk=law_enforcement_id).update(is_active=False)
        
        
    def get_all_law_enforcement(self):
        return LawEnforcement.objects.filter(is_active=True)
    
    def get_all_law_enforcement_by_establishment(self, establishment_id: int):
        law = LawEnforcement.objects.filter(establishment__id=establishment_id, is_active=True)
        print(law)
        return law
        
    
    
    def get_law_enforcement_by_establishment(self, establishment_id: int):
        establishment = get_object_or_404(Establishment, id=establishment_id)
        law_enforcements = establishment.lawenforcement_set.all().first()
        return law_enforcements
    
    def update_law_enforcement_by_establishment_id(self, establishment_id: int, law_enforcement: dict):
        establishment = get_object_or_404(Establishment, id=establishment_id)
        law_enforcements = establishment.lawenforcement_set.all()
        law_enforcements.update(**law_enforcement)
        return law_enforcements.first()