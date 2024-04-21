

from admin_service.celery import app
from celery import shared_task
from app_admin.domain.service.smtp_service import SmtpService
from app_admin.adapters.impl.smtp_impl import StmpImpl
from app_admin.utils.contants import EMAIL_FROM_NAME
from admin_service.settings import FRONTEND_PASSWORD_CONFIRMATION_URL, FRONTEND_ACTIVATE_ACCOUNT_URL
from django.utils.encoding import force_str
from django.utils.http import urlsafe_base64_decode, urlsafe_base64_encode
import random
import uuid

service = SmtpService(smtp_repository=StmpImpl())


def auth_send_password_reset_event(current_user_id, username, email, reset_password_url):
    data = {
        'type': 'auth_password_reset',
        'payload': {
            'current_user': current_user_id,
            'username': username,
            'email': email,
            'reset_password_url': reset_password_url
        },

    }

    context = data['payload']
    context['reset_password_url'] = FRONTEND_PASSWORD_CONFIRMATION_URL.replace(
        ':token', context['reset_password_url'])

    mail = service.send_email(email, 'Password Reset',
                              'Password Reset', '', '', '', current_user_id)
    service.send_email_with_template_and_context(
        mail, 'emails/password-reset/password-reset.html', context)
    print("TASK AUTH SEND PASSWORD RESET EVENT")
    return data


def auth_send_activate_account_event(email, uidb64, token, username):
    print(
        "TASK AUTH SEND ACTIVATE ACCOUNT EVENT  {email} {uidb64} {token} {username} ")
    data = {
        'type': 'auth_activate_account',
        'id': uuid.uuid4(),
        'payload': {
                'uidb64': uidb64,
                'username': username,
                'email': email,
                'token': token,
                'random': random.randint(1, 1000),
        },

    }

    context = data['payload']
    context['activate_account_url'] = FRONTEND_ACTIVATE_ACCOUNT_URL.replace(
        ':token', token).replace(':uidb64', uidb64)
    user_id = force_str(urlsafe_base64_decode(uidb64))

    mail = service.send_email(
        email, 'Activate Account ', 'Activate Account ', '', '', '', user_id)
    service.send_email_with_template_and_context(
        mail, 'emails/activate-account/activate-account.html', context)
    print("TASK AUTH SEND ACTIVATE ACCOUNT EVENT ")
