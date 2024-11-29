from django.db import models
from .base_model import BaseModel
from datetime import datetime


class Status(models.TextChoices):
    DRAFT = 'DRAFT', 'BORRADOR'
    SEND = 'SEND', 'ENVIADO'
    PRORROGA = 'PRORROGA','PRORROGA'
    RESPONSED = 'RESPONSED', 'RESPONDIDA'
    NO_RESPONSED = 'NO_RESPONSED', 'NO RESPONDIDA'
    INSISTENCY_PERIOD = 'INSISTENCY_PERIOD', 'PERIODO DE INSISTENCIA'
    INSISTENCY_SEND = 'INSISTENCY_SEND', 'INSISTENCIA ENVIADA'
    INSISTENCY_RESPONSED = 'INSISTENCY_RESPONSED', 'INSISTENCIA RESPONDIDA'
    INSISTENCY_NO_RESPONSED = 'INSISTENCY_NO_RESPONSED', 'INSISTENCIA NO RESPONDIDA'
    PERIOD_INFORMAL_MANAGEMENT = 'PERIOD_INFORMAL_MANAGEMENT', 'PERIODO DE GESTIÓN OFICIOSA'
    INFORMAL_MANAGMENT_SEND = 'INFORMAL_MANAGMENT_SEND', 'GESTIÓN OFICIOSA ENVIADA'
    INFORMAL_MANAGMENT_RESPONSED = 'INFORMAL_MANAGMENT_RESPONSED', 'GESTIÓN OFICIOSA RESPONDIDA'
    INFORMAL_MANAGMENT_NO_RESPONSED = 'INFORMAL_MANAGMENT_NO_RESPONSED', 'GESTIÓN OFICIOSA NO RESPONDIDA'
    FINISHED_WITHOUT_RESPONSE = 'FINISHED_WITHOUT_RESPONSE', 'FINALIZADO SIN RESPUESTA'
    FINISHED = 'FINISHED', 'FINALIZADO'


class TypeStages(models.TextChoices):
    SEND = 'SEND', 'ENVIADO'
    PENDING = 'PENDING', 'PENDIENTE'
    RESPONSE = 'RESPONSE', 'RESPUESTA'
    INSISTENCY = 'INSISTENCY', 'INSISTENCIA'
    PENDING_RESPONSE_INSISTENCY = 'PENDING_RESPONSE_INSISTENCY', 'PENDIENTE RESPUESTA INSISTENCIA'
    RESPONSE_INSISTENCY = 'RESPONSE_INSISTENCY', 'RESPUESTA INSISTENCIA'
    INFORMAL_MANAGEMENT = 'INFORMAL_MANAGEMENT', 'GESTIÓN OFICIOSA'


class Solicity(BaseModel):
    number_saip = models.CharField(max_length=255, null=True, blank=True)
    date = models.DateTimeField(default=datetime.now)
    city = models.CharField(max_length=255)

    text = models.TextField()
    establishment = models.ForeignKey(
        'EstablishmentExtended', on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    status = models.CharField(
        max_length=50, choices=Status.choices, default=Status.DRAFT)
    expiry_date = models.DateTimeField(null=True, blank=True)
    have_extension = models.BooleanField(default=False)
    is_manual = models.BooleanField(default=False)
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    email = models.EmailField()
    race_identification = models.CharField(max_length=255)
    gender = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    phone = models.CharField(max_length=255)
    format_send = models.CharField(max_length=255)
    format_receipt = models.CharField(max_length=255)
    objects = models.Manager()
    date_mail_send = models.DateTimeField(null=True, blank=True)
    class Meta:
        verbose_name = 'Solicitud'
        verbose_name_plural = 'Solicitudes'


class TimeLineSolicity(BaseModel):
    solicity = models.ForeignKey('Solicity', on_delete=models.CASCADE)
    status = models.CharField(
        max_length=255, choices=TypeStages.choices, default=TypeStages.PENDING)
    objects = models.Manager()

    class Meta:
        verbose_name = 'Historial de Solicitud'
        verbose_name_plural = 'Historiales de Solicitudes'

# solicitud de insistencia


class Insistency(BaseModel):
    solicity = models.ForeignKey('Solicity', on_delete=models.CASCADE)
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    status = models.CharField(
        max_length=50, choices=Status.choices, default=Status.SEND)
    expiry_date = models.DateTimeField(null=True, blank=True)
    motive = models.TextField()
    files = models.ManyToManyField('FilePublication', blank=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Insistencia'
        verbose_name_plural = 'Insistencias'


class SolicityResponse(BaseModel):
    text = models.TextField()
    solicity = models.ForeignKey('Solicity', on_delete=models.CASCADE)
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    files = models.ManyToManyField('FilePublication', blank=True)
    attachments = models.ManyToManyField('Attachment', blank=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Respuesta de Solicitud'
        verbose_name_plural = 'Respuestas de Solicitudes'


# prorroga
class Extension(BaseModel):
    solicity = models.ForeignKey('Solicity', on_delete=models.CASCADE)
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    status = models.CharField(
        max_length=50, choices=Status.choices, default=Status.SEND)
    expiry_date = models.DateTimeField(null=True, blank=True)
    motive = models.TextField()
    files = models.ManyToManyField('FilePublication', blank=True)
    attachments = models.ManyToManyField('Attachment', blank=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Prórroga'
        verbose_name_plural = 'Prórrogas'


class Category(BaseModel):
    name = models.CharField(max_length=255)
    description = models.TextField()
    is_active = models.BooleanField(default=True)
    objects = models.Manager()

    class Meta:
        verbose_name = 'Categoría'
        verbose_name_plural = 'Categorías'

    def __str__(self):
        return str(self.name)
