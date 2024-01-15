from django.core.mail import EmailMultiAlternatives
from django.dispatch import receiver
from django.template.loader import render_to_string
from django_rest_passwordreset.signals import reset_password_token_created

from shared.tasks.auth_task import auth_send_password_reset_event

@receiver(reset_password_token_created)
def password_reset_token_created(sender, instance, reset_password_token, *args, **kwargs):
    """
    Handles password reset tokens
    When a token is created, an e-mail needs to be sent to the user
    :param sender: View Class that sent the signal
    :param instance: View Instance that sent the signal
    :param reset_password_token: Token Model Object
    :param args:
    :param kwargs:
    :return:"""
    
    auth_send_password_reset_event.delay(
        
        current_user_id=reset_password_token.user.id,
        username=reset_password_token.user.username,
        email=reset_password_token.user.email,
        reset_password_url=reset_password_token.key
    )