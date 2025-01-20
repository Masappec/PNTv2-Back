from django.db import models

from entity_app.utils.functions import unique_slug_generator
from .base_model import BaseModel
import os
from django.conf import settings


class Publication(BaseModel):

    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    type_format = models.ManyToManyField(
        'TypeFormats', blank=True, related_name='publication_type_format')
    is_active = models.BooleanField(default=True, null=True, blank=True)
    tag = models.ManyToManyField(
        'Tag', blank=True, related_name='publication_tag')
    establishment = models.ForeignKey('EstablishmentExtended', on_delete=models.CASCADE,
                                      null=True, blank=True, related_name='publication_establishment')
    type_publication = models.ForeignKey(
        'TypePublication', on_delete=models.CASCADE, null=True, blank=True, related_name='publication_type_publication')
    file_publication = models.ManyToManyField(
        'FilePublication', blank=True, related_name='publication_file_publication')
    slug = models.SlugField(max_length=255, null=True,
                            blank=True, unique=True, editable=False, db_index=True)
    notes = models.TextField(null=True, blank=True)
    attachment = models.ManyToManyField(
        'Attachment', blank=True, related_name='publication_attachment')
    objects = models.Manager()

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = unique_slug_generator(self)
        super(Publication, self).save(*args, **kwargs)

    class Meta:
        verbose_name = 'Publicación'
        verbose_name_plural = 'Publicaciones'


class Attachment(BaseModel):
    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    url_download = models.URLField(max_length=255, null=True, blank=True)
    is_active = models.BooleanField(default=True, null=True, blank=True)
    objects = models.Manager()

    class Meta:
        verbose_name = 'Adjunto'
        verbose_name_plural = 'Adjuntos'


class FilePublication(BaseModel):

    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    url_download = models.FileField(
        upload_to='publications/', null=True, blank=True,
        max_length=255)
    is_active = models.BooleanField(default=True, null=True, blank=True)
    is_colab = models.BooleanField(default=False, null=True, blank=True)
    objects = models.Manager()
    file_join = models.ForeignKey(
        'FilePublication', on_delete=models.CASCADE, null=True, blank=True)

    class Meta:
        verbose_name = 'Archivo Publicación'
        verbose_name_plural = 'Archivo Publicaciones'

    @property
    def relative_url(self):
        return self.url_download.url

    @staticmethod
    def move_file(archivo_publicacion, nueva_ruta):
        """
        Método estático para mover un archivo asociado a una instancia de FilePublication a una nueva ruta.
        """
        if archivo_publicacion.url_download:
            # Construye el nombre del archivo en la nueva ubicación
            nueva_ruta_carpeta = settings.MEDIA_ROOT + nueva_ruta
            nueva_ruta_archivo = os.path.join(nueva_ruta_carpeta,
                                              archivo_publicacion.description+'.csv')
            # crea la carpeta si no existe
            if not os.path.exists(nueva_ruta_carpeta):
                os.makedirs(nueva_ruta_carpeta)
            os.rename(archivo_publicacion.url_download.path,
                      nueva_ruta_archivo)
            # Actualiza la ruta del archivo en la base de datos
            archivo_publicacion.url_download = os.path.join(
                nueva_ruta, archivo_publicacion.description+'.csv')
            # Guarda el objeto para reflejar los cambios en la base de datos
            archivo_publicacion.save()


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
