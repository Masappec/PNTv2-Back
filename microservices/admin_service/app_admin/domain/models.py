

from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType

# Create your models here.



class BaseModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    deleted = models.BooleanField(default=False, null=True, blank=True)
    deleted_at = models.DateTimeField(null=True, blank=True, default=None)
    user_created = models.ForeignKey('auth.User', on_delete=models.CASCADE, null=True, blank=True, related_name='%(class)s_user_created')
    user_updated = models.ForeignKey('auth.User', on_delete=models.CASCADE, null=True, blank=True, related_name='%(class)s_user_updated')
    user_deleted = models.ForeignKey('auth.User', on_delete=models.CASCADE, null=True, blank=True, related_name='%(class)s_user_deleted')
    
    class Meta:
        abstract = True
        
        verbose_name = 'BaseModel'
        
        
class UserEstablishment(BaseModel):
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE, null=True, blank=True)
    establishment = models.ForeignKey('Establishment', on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Usuario por Institución'
        verbose_name_plural = 'Usuarios por Institución'



class Establishment(BaseModel):
    
    name = models.CharField(max_length=255)
    code = models.CharField(max_length=255, null=True, blank=True, unique=True)
    abbreviation = models.CharField(max_length=255)
    logo = models.ImageField(upload_to='establishment')
    highest_authority = models.CharField(max_length=255)
    first_name_authority = models.CharField(max_length=255)
    last_name_authority = models.CharField(max_length=255)
    job_authority = models.CharField(max_length=255)
    email_authority = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    
    
    objects = models.Manager()

    class Meta:
        verbose_name = 'Institución'
        verbose_name_plural = 'Instituciones'
        
    #generate code secuence
    
    
    
        
        
        
    #permisos personalizados
    
    
    

class LawEnforcement(BaseModel):
    
    highest_committe = models.CharField(max_length=255)
    first_name_committe = models.CharField(max_length=255)
    last_name_committe = models.CharField(max_length=255)
    job_committe = models.CharField(max_length=255)
    email_committe = models.CharField(max_length=255)
    establishment = models.ManyToManyField(Establishment, related_name='lawenforcement_set')
    is_active = models.BooleanField(default=True)
    
    objects = models.Manager()
    
    class Meta:
        
        verbose_name = 'Comité de Transparencia'
        verbose_name_plural = 'Comités de Transparencia'
        
    
    
class AccessToInformation(BaseModel):
    email = models.CharField(max_length=255)
    establishment = models.ManyToManyField(Establishment, related_name='accesstoinformation_set')
    is_active = models.BooleanField(default=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Acceso a la Información'
        verbose_name_plural = 'Accesos a la Información'
    



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
    permission_required = models.CharField(max_length=255, null=True, blank=True)
    objects = models.Manager()
    
    
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE, null=True, blank=True)
    object_id = models.PositiveIntegerField(null=True, blank=True)
    content_object = GenericForeignKey('content_type', 'object_id')

    
    class Meta:
        verbose_name = 'Campo de Formulario'
        verbose_name_plural = 'Campos de Formulario'
        
        
    #create default rows
    def __str__(self):
        return self.role + " | "+ self.description 
    
    
    
class PedagogyArea(BaseModel):
    published = models.BooleanField(default=False)
    
    
class FrequentlyAskedQuestions(BaseModel):
    question = models.TextField()
    answer = models.TextField()
    pedagogy_area = models.ForeignKey(PedagogyArea, on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Pregunta Frecuente'
        verbose_name_plural = 'Preguntas Frecuentes'
        


class TutorialVideo(BaseModel):
    title = models.CharField(max_length=255)
    description = models.TextField()
    url = models.CharField(max_length=255)
    pedagogy_area = models.ForeignKey(PedagogyArea, on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Video Tutorial'
        verbose_name_plural = 'Videos Tutoriales'
        
    def __str__(self):
        return self.title
    
class NormativeDocument(BaseModel):
    title = models.CharField(max_length=255)
    description = models.TextField()
    url = models.CharField(max_length=255)
    pedagogy_area = models.ForeignKey(PedagogyArea, on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Documento Normativo'
        verbose_name_plural = 'Documentos Normativos'
        
    def __str__(self):
        return self.title
    
    
    

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
        return self.name
    
    #permisos personalizados
    
    

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
        return self.subject
    
    
    @staticmethod
    def STATUS_PENDING():
        return 'pending'
    
    @staticmethod
    def STATUS_SENT():
        return 'sent'
    
    @staticmethod
    def STATUS_ERROR():
        return 'error'