


from django.core.mail.backends.smtp import EmailBackend
from app_admin.ports.repositories.smtp_repository import SmtpRepository
from app_admin.domain.models import Email, Configuration
from datetime import datetime
from django.core import mail
from django.template.loader import render_to_string
import app_admin.utils.contants as constants
class StmpImpl(SmtpRepository):
    
    
    def send_email(self, email: Email, user_created: int):
        email.user_created__id = user_created
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
            html_content = render_to_string(template, context)
            message = mail.EmailMessage(
                subject=email.subject,
                body=html_content,
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
        config_save = Configuration.objects.filter(active=True, type_config=constants.KEY_SMTP_CONFIG)

        user = config_save.filter(name=constants.KEY_USER_SMTP).first()
        if 'user' in config:
            user.value = config['user']
            user.save()
            
        if 'password' in config:
            password = config_save.filter(name=constants.KEY_PASSWORD_SMTP).first()
            password.value = config['password']
            password.save()
            
        password = config_save.filter(name=constants.KEY_PASSWORD_SMTP).first()
        if 'password' in config:
            password.value = config['password']
            password.save()
        host = config_save.filter(name=constants.KEY_HOST_SMTP).first()
        if 'host' in config:
            host.value = config['host']
            host.save()
        port = config_save.filter(name=constants.KEY_PORT_SMTP).first()
        
        if 'port' in config:
            port.value = config['port']
            port.save()
        
        use_tls = config_save.filter(name=constants.KEY_USE_TLS_SMTP).first()
        
        if 'use_tls' in config:
            use_tls.value = config['use_tls']
            use_tls.save()
        
        
        
        return config_save
    
    
    def get_email_backend(self):
        try:
            config = Configuration.objects.filter(active=True, type_config=constants.KEY_SMTP_CONFIG)
            
            user = config.filter(name=constants.KEY_USER_SMTP).first()
            password = config.filter(name=constants.KEY_PASSWORD_SMTP).first()
            host = config.filter(name=constants.KEY_HOST_SMTP).first()
            port = config.filter(name=constants.KEY_PORT_SMTP).first()
            use_tls = config.filter(name=constants.KEY_USE_TLS_SMTP).first()
            
            return EmailBackend(
                host=host.value,
                port=port.value,
                username=user.value,
                password=password.value,
                use_tls=use_tls.value == 'True',
                timeout=25,
                
            )
        except Exception:
            raise Exception('No existe configuracion de SMTP')
        
    def get_config(self):
        config = Configuration.objects.filter(active=True, type_config=constants.KEY_SMTP_CONFIG)
        config_dict = {}
        for item in config:
            config_dict[item.name] = item.value
        return config_dict