

from app_admin.ports.repositories.user_estblishment_repository import UserEstablishmentRepository
from app_admin.domain.models import UserEstablishment
from django.utils.timezone import datetime


class UserEstablishmentImpl(UserEstablishmentRepository):

    def assign_user(self, user_id: int, establishment_id: int):
        user_establishment = UserEstablishment()
        user_establishment.user_id = user_id
        user_establishment.establishment_id = establishment_id
        user_establishment.created_at = datetime.now()
        user_establishment.user_created_id = user_id
        user_establishment.save()

        return user_establishment

    def get_user_by_establishment(self, establishment_id: int):
        return UserEstablishment.objects.filter(establishment_id=establishment_id)

    def get_establishment_by_user(self, user_id: int):
        return UserEstablishment.objects.filter(user_id=user_id)

    def remove_user(self, user_id: int, establishment_id: int):
        print("Eliminando usuario ", user_id, establishment_id)
        est = UserEstablishment.objects.filter(
            user_id=user_id, establishment_id=establishment_id).first()

        if est is None:
            return
        est.is_active = False
        est.save()

    def remove_all_users(self, establishment_id: int):
        UserEstablishment.objects.filter(
            establishment_id=establishment_id).update(is_active=False)
