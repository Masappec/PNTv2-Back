


from django.core.mail.backends.smtp import EmailBackend
from app_admin.ports.repositories.smtp_repository import SmtpRepository
from app_admin.domain.models import Email, Configuration
from datetime import datetime
from django.core import mail
from django.template.loader import render_to_string

class StmpImpl(SmtpRepository):
    
    
    def send_email(self, email: Email, user_created: str):
        email.user_created = user_created
        email.created_at = datetime.now()
        email.save()
    
    
    def send_email_with_template(self, email: Email, template: str, user_created: str, attachments: list):
        try:
            
            html_content = render_to_string(template, {'email': email})
            email.body = html_content
            
            email.user_created = user_created
            email.created_at = datetime.now()
            email.status = Email.STATUS_PENDING()
            email.save()
            message = mail.EmailMessage(
                subject=email.subject,
                body=html_content,
                from_email=email.from_email,
                to=email.to,
                bcc=email.bcc,
                cc=email.cc,
                attachments=attachments,
                reply_to=email.reply_to,
                )
            
            self.get_email_backend().send_messages([message])
            email.status = Email.STATUS_SENT()
            email.save()
        except Exception as e:
            email.status = Email.STATUS_ERROR()
            email.error = str(e)
            email.save()
            raise e

        
    
    
    def send_email_with_template_and_context(self, email: Email, template: str, context: dict):
        try:
            email.status = Email.STATUS_PENDING()
            email.save()
            message = mail.EmailMessage(
                subject=email.subject,
                body=template,
                from_email=email.from_email,
                to=email.to,
                bcc=email.bcc,
                cc=email.cc,
                reply_to=email.reply_to,
                )
            
            self.get_email_backend().send_messages([message])
            email.status = Email.STATUS_SENT()
            email.save()
            
        except Exception as e:
            email.status = Email.STATUS_ERROR()
            email.error = str(e)
            email.save()
            raise e
    
    def setup(self, config: dict):
        config_save = Configuration.objects.create(
            **config
        )
        
        return config_save
    
    
    def get_email_backend(self):
        config = Configuration.objects.filter(active=True, type_config='SMTP')
        
        user = config.filter(name='USER').first()
        password = config.filter(name='PASSWORD').first()
        host = config.filter(name='HOST').first()
        port = config.filter(name='PORT').first()
        use_tls = config.filter(name='USE_TLS').first()
        
        return EmailBackend(
            host=host.value,
            port=port.value,
            username=user.value,
            password=password.value,
            use_tls=use_tls.value == 'True',
            timeout=25,
            
        )