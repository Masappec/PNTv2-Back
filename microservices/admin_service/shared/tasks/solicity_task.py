from app_admin.domain.service.smtp_service import SmtpService
from app_admin.adapters.impl.smtp_impl import StmpImpl
from django.contrib.auth.models import User
from app_admin.models import Establishment
from admin_service.celery import app
from app_admin.utils.contants import EMAIL_FROM_NAME
from admin_service.settings import FRONTEND_PASSWORD_CONFIRMATION_URL, FRONTEND_ACTIVATE_ACCOUNT_URL
from typing import List
from django.utils import timezone


service = SmtpService(smtp_repository=StmpImpl())


def send_email_citizen_create_solicity(
    solicity_id: int,
    establishment_id: int,
    user_id: int,
    number_saip: str,
    email: List[str],

):
    print('Ejecutando tarea de envio de correo {0}'.format(timezone.now()))
    try:
        user = User.objects.get(id=user_id)

        establishment = Establishment.objects.get(id=establishment_id)
        context = {
            'first_name': user.first_name,
            'last_name': user.last_name,
            'saip': number_saip,
            'establishment': establishment.name,
            'url': FRONTEND_ACTIVATE_ACCOUNT_URL + f'/admin/reports/'
        }

        for _email in email:
            print('Enviando correo a {0} {1}'.format(_email, timezone.now()))
            mail = service.send_email(
                _email, 'Nueva Solicitud SAIP', 'Nueva Solicitud SAIP', '', '', '', user_id)
            service.send_email_with_template_and_context(
                mail, 'emails/solicity/establishment/citizen_create.html', context)

        mail = service.send_email(
            user.email, 'Nueva Solicitud SAIP', 'Nueva Solicitud SAIP', '', '', '', user_id)

        service.send_email_with_template_and_context(
            mail, 'emails/solicity/citizen/citizen_create.html', context)

        return True

    except Exception as e:
        print("TASK AUTH SEND ACTIVATE ACCOUNT EVENT ", e)
        return True


def send_email_establishment_response(
    solicity_id: int,
    establishment_id: int,
    user_id: int,
    number_saip: str,
    email: List[str],
):

    try:
        user = User.objects.get(id=user_id)

        establishment = Establishment.objects.get(id=establishment_id)
        context = {
            'first_name': user.first_name,
            'last_name': user.last_name,
            'saip': number_saip,
            'establishment': establishment.name,
            'url': FRONTEND_ACTIVATE_ACCOUNT_URL + f'/admin/solicity/'
        }

        for _email in email:
            mail = service.send_email(
                _email, 'Respuesta Solicitud SAIP', 'Respuesta Solicitud SAIP', '', '', '', user_id)
            service.send_email_with_template_and_context(
                mail, 'emails/solicity/establishment/establishment_response.html', context)
            service.print_message('Enviando correo a  {0} '.format(_email))

        mail = service.send_email(
            user.email, 'Respuesta Solicitud SAIP', 'Respuesta Solicitud SAIP', '', '', '', user_id)

        service.send_email_with_template_and_context(
            mail, 'emails/solicity/citizen/citizen_response.html', context)

    except Exception as e:
        print("TASK AUTH SEND ACTIVATE ACCOUNT EVENT ", e)
        return False


def send_mail_citizen_response(
    solicity_id: int,
    establishment_id: int,
    user_id: int,
    number_saip: str,
    email: List[str],
):

    try:
        user = User.objects.get(id=user_id)

        establishment = Establishment.objects.get(id=establishment_id)
        context = {
            'first_name': user.first_name,
            'last_name': user.last_name,
            'saip': number_saip,
            'establishment': establishment.name,
            'url': FRONTEND_ACTIVATE_ACCOUNT_URL + f'/admin/reports/'
        }

        for _email in email:
            mail = service.send_email(
                _email, 'Respuesta Solicitud SAIP', 'Respuesta Solicitud SAIP', '', '', '', user_id)
            service.send_email_with_template_and_context(
                mail, 'emails/solicity/citizen_response.html', context)
            service.print_message('Enviando correo a  {0}'.format(_email))

            service.print_message('Enviando correo a {0}'.format(_email))

        mail = service.send_email(
            user.email, 'Respuesta Solicitud SAIP', 'Respuesta Solicitud SAIP', '', '', '', user_id)

        service.send_email_with_template_and_context(
            mail, 'emails/solicity/establishment/establishment_response.html', context)
    except Exception as e:
        print("TASK AUTH SEND ACTIVATE ACCOUNT EVENT ", e)
        return False


def send_email_for_expired_citizen(
    solicity_id: int,
    establishment_id: int,
    user_id: int,
    number_saip: str,
    email: List[str],
    first_name: str,
    last_name: str,
    status: str,
    date: str
):
    print('Ejecutando tarea de envio de correo {0}'.format(timezone.now()))

    try:
        user = User.objects.get(id=user_id)

        establishment = Establishment.objects.get(id=establishment_id)
        context = {
            'first_name': user.first_name,
            'last_name': user.last_name,
            'saip': number_saip,
            'establishment': establishment.name,
            'url': FRONTEND_ACTIVATE_ACCOUNT_URL + f'/admin/solicity/'
        }

        for _email in email:
            mail = service.send_email(
                _email, 'Solicitud SAIP por vencer', 'Solicitud SAIP por vencer', '', '', '', user_id)
            service.send_email_with_template_and_context(
                mail, 'emails/solicity/for_expired_citizen.html', context)
    except Exception as e:
        print("TASK AUTH SEND ACTIVATE ACCOUNT EVENT ", e)
        return False


'''{"number_saip": "936909", "date": "2024-05-11", "first_name": "ASDASD", "last_name": "ASDASD", 
"establishment_id": 1291, "status": "SEND", "user_id": 3}'''


def send_email_for_expired_establishment(
    solicity_id: int,
    establishment_id: int,
    user_id: int,
    number_saip: str,
    email: List[str],
    first_name: str,
    last_name: str,
    status: str,
    date: str
):
    print('Ejecutando tarea de envio de correo {0}'.format(timezone.now()))
    try:
        user = User.objects.get(id=user_id)

        establishment = Establishment.objects.get(id=establishment_id)
        context = {
            'first_name': user.first_name,
            'last_name': user.last_name,
            'saip': number_saip,
            'establishment': establishment.name,
            'url': FRONTEND_ACTIVATE_ACCOUNT_URL + f'/admin/reports/'
        }

        for _email in email:
            mail = service.send_email(
                _email, 'Solicitud SAIP por vencer', 'Solicitud SAIP por vencer', '', '', '', user_id)
            service.send_email_with_template_and_context(
                mail, 'emails/solicity/for_expired_establishment.html', context)
    except Exception as e:
        print("TASK AUTH SEND ACTIVATE ACCOUNT EVENT ", e)
        return False
