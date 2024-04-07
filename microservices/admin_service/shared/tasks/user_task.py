from admin_service.celery import app
from celery import shared_task
from app_admin.domain.service.user_establishment_service import UserEstablishmentService

from app_admin.domain.service.user_establishment_service import UserEstablishmentService
from app_admin.adapters.impl.user_establishment_impl import UserEstablishmentImpl


def send_user_created_event(user_id, establishment_id):

    try:
        if not user_id:
            raise ValueError("El id del usuario no puede ser nulo")
        if not establishment_id:
            raise ValueError("El id del establecimiento no puede ser nulo")

        service = UserEstablishmentService(UserEstablishmentImpl())
        establishments = service.get_establishment_by_user(user_id)
        for establishment in establishments:
            service.remove_user(user_id, establishment.establishment_id)

        establishments = service.get_establishment_by_user(user_id)

        print([establishment.is_active for establishment in establishments])
        service.assign_user(user_id, establishment_id)

    except Exception as e:
        print(f"Task failed: Error al asignar usuario {
              user_id} al establecimiento {establishment_id}")
        raise e
