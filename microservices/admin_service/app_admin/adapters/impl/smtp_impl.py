

from django.core.mail.backends.smtp import EmailBackend
from app_admin.ports.repositories.smtp_repository import SmtpRepository
from app_admin.domain.models import Email, Configuration
from datetime import datetime
from django.core import mail
from django.template.loader import render_to_string
import app_admin.utils.contants as constants


class StmpImpl(SmtpRepository):

    def send_email(self, to_email: str, subject: str, body: str, bcc: str, cc: str, reply_to: str, user_id: int):
        email_from = self.get_config()[constants.KEY_USER_SMTP]
        print('email_from ', email_from)
        return Email.objects.create(
            from_email=email_from,
            to_email=to_email,
            subject=subject,
            body=body,
            bcc=bcc,
            cc=cc,
            reply_to=reply_to,
            status=Email.STATUS_PENDING(),
            user_created_id=user_id
        )

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
                to=[email.to_email],
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
            print('send_email_with_template_and_context ', email)
            html_content = render_to_string(template, context)
            email.body = html_content
            email.status = Email.STATUS_PENDING()
            # email.save()
            message = mail.EmailMessage(
                subject=email.subject,
                body=html_content,
                from_email=email.from_email,
                to=[email.to_email],
                bcc=email.bcc,
                cc=email.cc,
                reply_to=email.reply_to,
            )

            backend = self.get_email_backend()
            count = backend.send_messages([message])
            print('count ', count)
            email.status = Email.STATUS_SENT()
            email.save()

        except Exception as e:
            email.status = Email.STATUS_ERROR()
            email.error = str(e)
            email.save()
            raise e

    def setup(self, config: dict):
        config_save = Configuration.objects.filter(
            is_active=True, type_config=constants.KEY_SMTP_CONFIG)

        user = config_save.filter(name=constants.KEY_USER_SMTP).first()
        if constants.KEY_USER_SMTP in config:
            user.value = config[constants.KEY_USER_SMTP]
            user.save()

        if constants.KEY_PASSWORD_SMTP in config:
            password = config_save.filter(
                name=constants.KEY_PASSWORD_SMTP).first()
            password.value = config[constants.KEY_PASSWORD_SMTP]
            password.save()

        host = config_save.filter(name=constants.KEY_HOST_SMTP).first()
        if constants.KEY_HOST_SMTP in config:
            host.value = config[constants.KEY_HOST_SMTP]
            host.save()
        port = config_save.filter(name=constants.KEY_PORT_SMTP).first()

        if constants.KEY_PORT_SMTP in config:
            port.value = config[constants.KEY_PORT_SMTP]
            port.save()

        use_tls = config_save.filter(name=constants.KEY_USE_TLS_SMTP).first()

        if constants.KEY_USE_TLS_SMTP in config:
            use_tls.value = config[constants.KEY_USE_TLS_SMTP]
            use_tls.save()

        return config_save

    def get_email_backend(self):
        try:
            config = Configuration.objects.filter(
                is_active=True, type_config=constants.KEY_SMTP_CONFIG)

            user = config.filter(name=constants.KEY_USER_SMTP).first()
            password = config.filter(name=constants.KEY_PASSWORD_SMTP).first()
            host = config.filter(name=constants.KEY_HOST_SMTP).first()
            port = config.filter(name=constants.KEY_PORT_SMTP).first()
            use_tls = config.filter(name=constants.KEY_USE_TLS_SMTP).first()

            print(host.value, port.value, user.value,
                  password.value, use_tls.value)
            return EmailBackend(
                host=host.value,
                port=port.value,
                username=user.value,
                password=password.value,
                use_tls=use_tls.value == 'True',
                timeout=25,

            )
        except Exception as e:
            raise Exception('Error al obtener configuración de SMTP')

    def get_config(self):
        config = Configuration.objects.filter(
            is_active=True, type_config=constants.KEY_SMTP_CONFIG)
        config_dict = {}
        for item in config:
            config_dict[item.name] = item.value
        return config_dict

    def get_config_list_obj(self):
        config = Configuration.objects.filter(
            is_active=True, type_config=constants.KEY_SMTP_CONFIG)
        return config
