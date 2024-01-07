
from django.dispatch import receiver
from django_rest_passwordreset.signals import reset_password_token_created
from shared.tasks.auth_task import auth_send_password_reset_event

@receiver(reset_password_token_created)
def password_reset_token_created(sender, instance, reset_password_token, *args, **kwargs):
    """
    Metodo que envia el correo de recuperacion de contraseña
    """
    auth_send_password_reset_event.delay(
        current_user=reset_password_token.user,
        username=reset_password_token.user.username,
        email=reset_password_token.user.email,
        reset_password_url=reset_password_token.key
    )
    