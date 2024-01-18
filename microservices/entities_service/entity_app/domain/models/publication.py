from django.db import models
from .base_model import BaseModel

class Publication(BaseModel):
    
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    type_format = models.ManyToManyField('TypeFormats', blank=True, related_name='publication_type_format')
    is_active = models.BooleanField(default=True, null=True, blank=True)
    tag = models.ManyToManyField('Tag', blank=True, related_name='publication_tag')
    establishment = models.ForeignKey('EstablishmentExtended', on_delete=models.CASCADE, null=True, blank=True, related_name='publication_establishment')
    


class FilePublication(BaseModel):
    
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    url_download = models.FileField(upload_to='publications/', null=True, blank=True)
    publication = models.ForeignKey('Publication', on_delete=models.CASCADE, null=True, blank=True, related_name='file_publication_publication')
    is_active = models.BooleanField(default=True, null=True, blank=True)
    

class TypePublication(BaseModel):
    
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    publication = models.ForeignKey('Publication', on_delete=models.CASCADE, null=True, blank=True, related_name='type_publication_publication')
    is_active = models.BooleanField(default=True, null=True, blank=True)
    
    
class Tag(BaseModel):
    
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    is_active = models.BooleanField(default=True, null=True, blank=True)
    

    