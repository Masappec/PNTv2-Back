from django.core.mail import EmailMultiAlternatives
from django.dispatch import receiver
from django.template.loader import render_to_string
from django_rest_passwordreset.signals import reset_password_token_created

from app.adapters.messaging.channels import CHANNEL_USER
from app.adapters.messaging.events import USER_PASSWORD_RESET_REQUESTED
from app.adapters.messaging.publish import Publisher
import json


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

    publisher = Publisher(CHANNEL_USER)

    publisher.publish({
        'type': USER_PASSWORD_RESET_REQUESTED,
        'payload': {
            'current_user_id': reset_password_token.user.id,
            'username': reset_password_token.user.username,
            'email': reset_password_token.user.email,
            'reset_password_url': reset_password_token.key
        }
    })
