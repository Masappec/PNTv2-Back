from abc import ABC, abstractmethod

from app_admin.domain.models import Configuration, Email
from django.core.mail.backends.smtp import EmailBackend


class SmtpRepository(ABC):
    @abstractmethod
    def send_email(self, to_email: str, subject: str, body: str,bcc:str, cc:str, reply_to:str,user_id:int) -> Email:
        pass
    
    
    @abstractmethod
    def send_email_with_template(self, email: Email, template: str) -> Email:
        pass
    
    
    @abstractmethod
    def send_email_with_template_and_context(self, email: Email, template: str, context: dict) -> Email:
        pass
    
    
    def setup(self, config: dict) -> Configuration:
        pass
    
    
    def get_email_backend(self) -> EmailBackend:
        pass
    
    def get_config(self) -> list:
        pass
    
    def get_config_list_obj(self) -> list:
        pass