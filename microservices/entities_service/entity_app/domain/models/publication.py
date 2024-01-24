from django.db import models

from entity_app.utils.functions import unique_slug_generator
from .base_model import BaseModel

class Publication(BaseModel):
    
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    type_format = models.ManyToManyField('TypeFormats', blank=True, related_name='publication_type_format')
    is_active = models.BooleanField(default=True, null=True, blank=True)
    tag = models.ManyToManyField('Tag', blank=True, related_name='publication_tag')
    establishment = models.ForeignKey('EstablishmentExtended', on_delete=models.CASCADE, null=True, blank=True, related_name='publication_establishment')
    type_publication = models.ForeignKey('TypePublication', on_delete=models.CASCADE, null=True, blank=True, related_name='publication_type_publication')
    file_publication = models.ManyToManyField('FilePublication', blank=True, related_name='publication_file_publication')
    slug = models.SlugField(max_length=255, null=True, blank=True, unique=True, editable=False, db_index=True)
    notes = models.TextField(null=True, blank=True)
    objects = models.Manager()
    
    
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = unique_slug_generator(self)
        super(Publication, self).save(*args, **kwargs)

 
    
    class Meta:
        verbose_name = 'Publicación'
        verbose_name_plural = 'Publicaciones'

class FilePublication(BaseModel):
    
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    url_download = models.FileField(upload_to='publications/', null=True, blank=True)
    is_active = models.BooleanField(default=True, null=True, blank=True)

    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Archivo Publicación'
        verbose_name_plural = 'Archivo Publicaciones'

    
class TypePublication(BaseModel):
    
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    is_active = models.BooleanField(default=True, null=True, blank=True)
    code = models.CharField(max_length=255, null=True, blank=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Tipo de Publicación'
        verbose_name_plural = 'Tipos de Publicaciones'
    
    
class Tag(BaseModel):
    
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    is_active = models.BooleanField(default=True, null=True, blank=True)
    
    objects = models.Manager()
    
    class Meta:
        verbose_name = 'Etiqueta'
        verbose_name_plural = 'Etiquetas'

    