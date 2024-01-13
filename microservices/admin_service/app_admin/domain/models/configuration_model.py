from django.db import models
from .base_model import BaseModel

class Configuration(BaseModel):
    
    name = models.CharField(max_length=255)
    value = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    type_config = models.CharField(max_length=255, null=True, blank=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Configuración'
        verbose_name_plural = 'Configuraciones'
        permissions = (
            ('can_view_configuration', 'Can view configuration'),

        )

    def __str__(self):
        return str(self.name) + " | " + str(self.value)

    # permisos personalizados

