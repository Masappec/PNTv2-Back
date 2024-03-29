from app_admin.ports.repositories.type_organization_repository import TypeOrganizationRepository
from app_admin.models import TypeOrganization


class TypeOrganizationImpl(TypeOrganizationRepository):
    def get_all(self):
        return TypeOrganization.objects.all()


    def create_type_organization(self, name: str):
        return TypeOrganization.objects.create(name=name)