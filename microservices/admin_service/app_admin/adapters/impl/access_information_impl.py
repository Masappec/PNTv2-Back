

from app_admin.domain.models import AccessToInformation, Establishment
from app_admin.ports.repositories.access_information_repository import AccessInformationRepository
from django.shortcuts import get_object_or_404


class AccessInformationImpl(AccessInformationRepository):

    def get_access_information(self, access_information_id: int):
        return AccessToInformation.objects.get(pk=access_information_id)

    def create_access_information(self, access_information: dict):
        return AccessToInformation.objects.create(**access_information)

    def update_access_information(self, access_information_id: int, access_information: dict):
        access = AccessToInformation.objects.filter(pk=access_information_id)
        access.update(**access_information)

    def delete_access_information(self, access_information_id: int):
        AccessToInformation.objects.filter(
            pk=access_information_id).update(is_active=False)

    def get_all_access_information(self):
        return AccessToInformation.objects.filter(is_active=True)

    def get_all_access_information_by_establishment(self, establishment_id: int):
        return AccessToInformation.objects.filter(is_active=True, establishment_id=establishment_id)

    def assign_establishment_to_access_information(self, access_information_id: int, establishment: Establishment):
        access = AccessToInformation.objects.get(pk=access_information_id)
        access.establishment.add(establishment)
        access.save()

    def remove_establishment_to_access_information(self, access_information_id: int, establishment_id: int):
        access = AccessToInformation.objects.get(pk=access_information_id)
        access.is_active = False
        access.save()

    def update_access_information_by_establishment_id(self, establishment_id: int, access_information: dict):
        establishment = get_object_or_404(Establishment, id=establishment_id)
        access_information_selected = establishment.accesstoinformation_set.all()
        if access_information_selected.count() > 0:
            access_information_selected.update(**access_information)
            return access_information_selected.first()
        else:
            access_information_selected = AccessToInformation.objects.create(
                **access_information)
            access_information_selected.establishment.add(establishment)
            access_information_selected.save()
            return access_information_selected
