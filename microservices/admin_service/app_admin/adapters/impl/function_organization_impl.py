from app_admin.ports.repositories.function_organization_repository import FunctionOrganizationRepository
from app_admin.models import FunctionOrganization


class FunctionOrganizationImpl(FunctionOrganizationRepository):
    def get_all(self):
        return FunctionOrganization.objects.all()

    def create_function_organization(self, name: str):
        return FunctionOrganization.objects.create(name=name)
 