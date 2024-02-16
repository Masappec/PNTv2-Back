
from .base_model import BaseModel
from django.db import models

class TypeEstablishment(BaseModel):
    name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    code = models.CharField(max_length=255, null=True, blank=True, unique=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Tipo de Institución'
        verbose_name_plural = 'Tipos de Instituciones'
    