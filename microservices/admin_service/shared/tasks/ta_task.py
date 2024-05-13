from celery import shared_task
from admin_service.celery import app
from app_admin.models import Establishment, UserEstablishment
from app_admin.domain.service.smtp_service import SmtpService
from app_admin.adapters.impl.smtp_impl import StmpImpl
from django.conf import settings


@shared_task(bind=True)
def process_created_transparency_active_entity(self):
    pass


@app.task()
def send_recordatory_ta(self):
    list_ = Establishment.objects.filter(is_active=True)

    service = SmtpService(smtp_repository=StmpImpl())

    users = UserEstablishment.objects.filter(establishment__in=list_)
    # recordatory_for_upload.html

    for user in users:
        context = {
            'establishment': user.establishment.name,
            'date': settings.DATE_MAX_FOR_UPLOAD_TA
        }
        mail = service.send_email(
            user.user.email, 'Recordatorio para subir la TA', '', '', '', '', user.user.id)
        service.send_email_with_template_and_context(
            mail, 'emails/ta/recordatory_for_upload.html', context)
