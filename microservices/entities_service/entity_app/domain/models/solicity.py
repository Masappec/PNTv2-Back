from django.db import models
from .base_model import BaseModel

class Status(models.TextChoices):
    CREATED = 'CREATED', 'CREADO'
    PENDING = 'PENDING', 'PENDIENTE'
    READING = 'READING', 'LEÍDO'
    PROCESSING = 'PROCESSING', 'EN PROCESO'
    FINISHED = 'FINISHED', 'FINALIZADO'
    
    
class Solicity(BaseModel):
    title = models.CharField(max_length=255)
    text = models.TextField()
    establishment = models.ForeignKey('EstablishmentExtended', on_delete=models.CASCADE)
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.CREATED)
    expiry_date = models.DateTimeField(null=True, blank=True)
    have_extension = models.BooleanField(default=False)
    
    
    class Meta:
        verbose_name = 'Solicitud'
        verbose_name_plural = 'Solicitudes'
    


#solicitud de insistencia
class Insistency(BaseModel):
    solicity = models.ForeignKey('Solicity', on_delete=models.CASCADE)
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.CREATED)
    expiry_date = models.DateTimeField(null=True, blank=True)
    motive = models.TextField()
    
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
    category = models.ForeignKey('Category', on_delete=models.CASCADE, null=True, blank=True)
    
    class Meta:
        verbose_name = 'Respuesta de Solicitud'
        verbose_name_plural = 'Respuestas de Solicitudes'


#prorroga 
class Extension(BaseModel):
    solicity = models.ForeignKey('Solicity', on_delete=models.CASCADE)
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.CREATED)
    expiry_date = models.DateTimeField(null=True, blank=True)
    motive = models.TextField()
    
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
        return self.name
    