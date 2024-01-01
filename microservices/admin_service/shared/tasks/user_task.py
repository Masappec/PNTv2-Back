from admin_service.celery import app
from celery import shared_task
from app_admin.domain.service.user_establishment_service import UserEstablishmentService

from app_admin.domain.service.user_establishment_service import UserEstablishmentService
from app_admin.adapters.impl.user_establishment_impl import UserEstablishmentImpl

@shared_task
def send_user_created_event(user_id, establishment_id):
    
    try:
        print("TAREA RECIEN CREADA")
        service = UserEstablishmentService(UserEstablishmentImpl())

        user = service.assign_user(user_id, establishment_id)
        print(f"Task success: User {user_id} assigned to establishment {establishment_id}")
        return {'type': 'user_created', 'payload': {'user_id': user_id, 'establishment_id': establishment_id}}
    
    except Exception as e:
        print(f"Task failed: Error al asignar usuario {user_id} al establecimiento {establishment_id}")
        return {'type': 'user_created', 'payload': {'user_id': user_id, 'establishment_id': establishment_id, 'error': str(e)}}