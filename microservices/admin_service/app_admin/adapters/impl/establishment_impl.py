from app_admin.ports.repositories.establishment_repository import EstablishmentRepository
from app_admin.domain.models import Establishment
from datetime import datetime
from django.utils import timezone
class EstablishmentRepositoryImpl(EstablishmentRepository):
    
    
    
    def get_all_establishments(self):
        return Establishment.objects.all()
    
    def get_establishment_by_abbr(self, abbreviation: str):
        return Establishment.objects.get(abbreviation=abbreviation)
    
    def get_first_access_to_information(self, establishment_id: int):
        return Establishment.objects.get(id=establishment_id).accesstoinformation_set.first()
    
    
    def get_establishment_by_name(self, name: str):
        return Establishment.objects.get(name=name)
    
    
    def get_establishment(self, establishment_id: int):
        return Establishment.objects.get(id=establishment_id)
    
    def get_first_law_enforcement(self, establishment_id: int):
        return Establishment.objects.get(id=establishment_id).lawenforcement_set.first()
    
    
    def get_first_law_enforcement_by_establishment(self, establishment_id: int):
        return Establishment.objects.get(id=establishment_id).lawenforcement_set.first()
    
    
    def create_establishment(self, establishment: dict, file):
        return Establishment.objects.create(
            name=establishment['name'],
            abbreviation=establishment['abbreviation'],
            deleted=False,
            created_at=datetime.now(),
            updated_at=datetime.now(),
            code=establishment['code'],
            logo = file,
            highest_authority=establishment['highest_authority'],
            first_name_authority=establishment['first_name_authority'],
            last_name_authority=establishment['last_name_authority'],
            job_authority=establishment['job_authority'],
                
        )
    
    
    def delete_establishment(self, establishment_id: int):
        establishment = Establishment.objects.get(id=establishment_id)
        establishment.deleted = True
        establishment.deleted_at = timezone.now()
        establishment.save()
        return establishment
    
    def assign_access_to_information(self, access_to_information_id: int, establishment_id: int):
        establishment = Establishment.objects.get(id=establishment_id)
        establishment.accesstoinformation_set.add(access_to_information_id)
        establishment.save()
        return establishment
    
    
    def assign_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        establishment = Establishment.objects.get(id=establishment_id)
        establishment.lawenforcement_set.add(law_enforcement_id)
        establishment.save()
        return establishment
    
    
    
    def remove_access_to_information(self, access_to_information_id: int, establishment_id: int):
        establishment = Establishment.objects.get(id=establishment_id)
        access = establishment.accesstoinformation_set.get(id=access_to_information_id)
        access.deleted = True
        access.deleted_at = datetime.now()
        access.save()
    
    
    def remove_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        establishment = Establishment.objects.get(id=establishment_id)
        law = establishment.lawenforcement_set.get(id=law_enforcement_id)
        law.deleted = True
        law.deleted_at = datetime.now()
        law.save()
        
    def update_establishment(self, establishment_id: int, establishment: dict):
        establishment = Establishment.objects.get(id=establishment_id)
        establishment.update(**establishment)
        return establishment
    
    
    
    
    def remove_all_law_enforcement(self, establishment_id: int):
        establishment = Establishment.objects.get(id=establishment_id)
        establishment.lawenforcement_set.all().update(deleted=True, deleted_at=datetime.now())
        establishment.save()
        return establishment
    
    def remove_all_access_to_information(self, establishment_id: int):
        establishment = Establishment.objects.get(id=establishment_id)
        establishment.accesstoinformation_set.all().update(deleted=True, deleted_at=datetime.now())
        establishment.save()
        return establishment
    
    def get_establishment_by_abbreviation(self, abbreviation: str):
        return Establishment.objects.get(abbreviation=abbreviation)