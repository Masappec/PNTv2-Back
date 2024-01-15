from django.db import models
from .pedagogy_area_model import PedagogyArea
from .base_model import BaseModel


class FrequentlyAskedQuestions(BaseModel):
    question = models.TextField()
    answer = models.TextField()
    pedagogy_area = models.ForeignKey(
        PedagogyArea, on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Pregunta Frecuente'
        verbose_name_plural = 'Preguntas Frecuentes'

