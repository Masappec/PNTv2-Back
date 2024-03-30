

from app_admin.ports.repositories.user_estblishment_repository import UserEstablishmentRepository
from django.core.exceptions import ObjectDoesNotExist


class UserEstablishmentService:

    def __init__(self, user_establishment_repository: UserEstablishmentRepository):
        self.user_establishment_repository = user_establishment_repository

    def assign_user(self, user_id: int, establishment_id: int):
        try:
            return self.user_establishment_repository.assign_user(user_id, establishment_id)

        except ObjectDoesNotExist as e:
            raise ValueError(
                f"El usuario o el establecimiento no existen : {e}")
        except Exception as e:
            raise ValueError(
                f"Error al asignar usuario al establecimiento: {e}")

    def get_user_by_establishment(self, establishment_id: int):
        try:
            return self.user_establishment_repository.get_user_by_establishment(establishment_id)

        except ObjectDoesNotExist as e:
            raise ValueError(f"El establecimiento no existe: {e}")
        except Exception as e:
            raise ValueError(
                f"Error al obtener usuarios por establecimiento: {e}")

    def get_establishment_by_user(self, user_id: int):
        try:
            return self.user_establishment_repository.get_establishment_by_user(user_id)

        except ObjectDoesNotExist as e:
            raise ValueError(f"El usuario no existe: {e}")
        except Exception as e:
            raise ValueError(
                f"Error al obtener establecimientos por usuario: {e}")

    def remove_user(self, user_id: int, establishment_id: int):
        try:
            return self.user_establishment_repository.remove_user(user_id, establishment_id)

        except ObjectDoesNotExist as e:
            raise ValueError(
                f"El usuario o el establecimiento no existen: {e}")
        except Exception as e:
            raise ValueError(
                f"Error al eliminar usuario del establecimiento: {e}")

    def remove_all_users(self, establishment_id: int):
        try:
            return self.user_establishment_repository.remove_all_users(establishment_id)

        except ObjectDoesNotExist as e:
            raise ValueError(f"El establecimiento no existe: {e}")
        except Exception as e:
            raise ValueError(
                f"Error al eliminar usuarios del establecimiento: {e}")
