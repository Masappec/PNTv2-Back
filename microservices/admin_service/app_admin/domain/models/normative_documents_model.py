from django.db import models
from .pedagogy_area_model import PedagogyArea
from .base_model import BaseModel


class NormativeDocument(BaseModel):
    title = models.CharField(max_length=255)
    description = models.TextField()
    url = models.CharField(max_length=255)
    pedagogy_area = models.ForeignKey(
        PedagogyArea, on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Documento Normativo'
        verbose_name_plural = 'Documentos Normativos'



    def __str__(self):
        return str(self.title) + " | " + str(self.description)