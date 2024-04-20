from django.db import models
from .base_model import BaseModel


class Email(BaseModel):
    from_email = models.CharField(max_length=255)
    to_email = models.CharField(max_length=255)
    subject = models.CharField(max_length=255)
    body = models.TextField()
    status = models.CharField(max_length=255, null=True, blank=True, choices=(
        ('pending', 'Pendiente'),
        ('sent', 'Enviado'),
        ('error', 'Error'),
    ))
    error = models.TextField(null=True, blank=True)
    bcc = models.CharField(max_length=255, null=True, blank=True)
    cc = models.CharField(max_length=255, null=True, blank=True)
    reply_to = models.CharField(max_length=255, null=True, blank=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Email'
        verbose_name_plural = 'Emails'

    def __str__(self):
        return str(self.subject) + " | " + str(self.to_email)

    @staticmethod
    def STATUS_PENDING():
        return 'pending'

    @staticmethod
    def STATUS_SENT():
        return 'sent'

    @staticmethod
    def STATUS_ERROR():
        return 'error'
