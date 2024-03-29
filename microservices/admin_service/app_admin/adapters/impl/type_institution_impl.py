from app_admin.ports.repositories.type_institution_repository import TypeInstutionRepository
from app_admin.models import TypeInstitution


class TypeInstitutionImpl(TypeInstutionRepository):

    def get_all(self):
        return TypeInstitution.objects.all()


    def create_type_institution(self, name: str):
        return TypeInstitution.objects.create(name=name)