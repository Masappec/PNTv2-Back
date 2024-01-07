

from auth_service.celery import app
from celery import shared_task
from app_admin.domain.service.smtp_service import SmtpService
from app_admin.adapters.impl.smtp_impl import StmpImpl


@shared_task
def auth_send_password_reset_event(current_user, username, email, reset_password_url):
    data = {
        'type': 'auth_password_reset',
        'payload': {
            'current_user': current_user,
            'username': username,
            'email': email,
            'reset_password_url': reset_password_url
        },

    }
    

    service = SmtpService(smtp_repository=StmpImpl())
    service.send_email_with_template_and_context(email,'email/password_reset/password_reset.html', data['payload'])
    
    return data
