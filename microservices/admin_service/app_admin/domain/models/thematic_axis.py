from .base_model import BaseModel
from django.db import models

class ThematicAxis(BaseModel):
    name = models.CharField(max_length=255)
    description = models.TextField()
    is_active = models.BooleanField(default=True)
    code = models.CharField(max_length=255, null=True, blank=True, unique=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Eje Temático'
        verbose_name_plural = 'Ejes Temáticos'
    
    def __str__(self):
        return str(self.name)