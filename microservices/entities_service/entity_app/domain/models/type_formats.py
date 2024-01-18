from django.db import models
from .base_model import BaseModel





class TypeFormats(BaseModel):
    name=models.CharField(max_length=255, null=True, blank=True)
    description=models.TextField(null=True, blank=True)
    