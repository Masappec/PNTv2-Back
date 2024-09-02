from django.db import models
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey
from .base_model import BaseModel


class FormFields(BaseModel):
    name = models.CharField(max_length=255)
    description = models.CharField(max_length=255)
    form_type = models.CharField(max_length=255)
    model = models.CharField(max_length=255, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    order = models.IntegerField(default=0)
    role = models.CharField(max_length=255, null=True, blank=True)
    type_field = models.CharField(max_length=255, null=True, blank=True, choices=(
        ('text', 'Texto'),
        ('password', 'Contraseña'),
        ('email', 'Email'),
        ('tel', 'Teléfono'),
        ('number', 'Número'),
        ('date', 'Fecha'),
        ('file', 'Archivo'),
        ('select', 'Selección'),
        ('radio', 'Radio'),
        ('checkbox', 'Checkbox'),
        ('textarea', 'Textarea'),
    ))
    options = models.JSONField(null=True, blank=True)
    permission_required = models.CharField(
        max_length=255, null=True, blank=True)
    objects = models.Manager()

    content_type = models.ForeignKey(
        ContentType, on_delete=models.CASCADE, null=True, blank=True)
    object_id = models.PositiveIntegerField(null=True, blank=True)
    content_object = GenericForeignKey('content_type', 'object_id')
    helptext = models.CharField(max_length=255, null=True, blank=True)

    class Meta:
        verbose_name = 'Campo de Formulario'
        verbose_name_plural = 'Campos de Formulario'

    # create default rows

    def __str__(self):
        return self.role + " | " + self.description
