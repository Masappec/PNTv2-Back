


from app_admin.domain.models import Email
from app_admin.ports.repositories.smtp_repository import SmtpRepository


class SmtpService:
    
    def __init__(self, smtp_repository: SmtpRepository):
        self.smtp_repository = smtp_repository

        
    def send_email(self,  to_email: str, subject: str, body: str,bcc:str, cc:str, reply_to:str,user_id:int):
        return self.smtp_repository.send_email( to_email, subject, body, bcc, cc, reply_to, user_id)
    
    def send_email_with_template(self, email: Email, template: str, user_created: str, attachments: list):
        return self.smtp_repository.send_email_with_template(email, template, user_created, attachments)
    
    
    def send_email_with_template_and_context(self, email: Email, template: str, context: dict):
        return self.smtp_repository.send_email_with_template_and_context(email, template, context)
    
    
    def setup(self, config: dict):
        return self.smtp_repository.setup(config)
    
    
    def get_email_backend(self):
        return self.smtp_repository.get_email_backend()
    
    def get_config(self):
        return self.smtp_repository.get_config()
    
    def get_config_list_obj(self):
        return self.smtp_repository.get_config_list_obj()