#
import datetime
from entity_app.utils.functions import unique_slug_generator, unique_code_generator
from .base_model import BaseModel
from django.db import models


class EstablishmentNumeral(BaseModel):
    establishment = models.ForeignKey(
        'EstablishmentExtended', on_delete=models.CASCADE, related_name='numerals')
    numeral = models.ForeignKey(
        'Numeral', on_delete=models.CASCADE, related_name='establishments')
    value = models.TextField()

    objects = models.Manager()

    class Meta:
        verbose_name = 'Numeral de Establecimiento'
        verbose_name_plural = 'Numerales de Establecimiento'
        unique_together = ('establishment', 'numeral')


class Numeral(BaseModel):
    name = models.CharField(max_length=255)
    description = models.TextField()
    templates = models.ManyToManyField(
        'TemplateFile', related_name='numerals', blank=True)
    parent = models.ForeignKey(
        'self', on_delete=models.CASCADE, related_name='children', null=True, blank=True)
    is_default = models.BooleanField(default=True)
    is_selected = models.BooleanField(default=False)
    type_transparency = models.CharField(max_length=255, choices=(
        ('A', 'Activa'), ('P', 'Pasiva'), ('C', 'Colaborativa'), ('F', 'Focalizada')), default='A')
    objects = models.Manager()

    class Meta:
        verbose_name = 'Numeral'
        verbose_name_plural = 'Numerales'

    def __str__(self):
        return str(self.name)


class TemplateFile(BaseModel):

    name = models.CharField(max_length=255)
    code = models.CharField(max_length=255, null=True, blank=True, unique=True)
    description = models.TextField()
    is_active = models.BooleanField(default=True)
    vertical_template = models.BooleanField(default=False)
    max_inserts = models.IntegerField(null=True, blank=True)
    columns = models.ManyToManyField(
        'ColumnFile', related_name='templates', blank=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Plantilla de Archivo'
        verbose_name_plural = 'Plantillas de Archivos'

    def __str__(self) -> str:
        numeral = ''
        if self.numerals.exists():
            numeral = self.numerals.first().name
        return str(self.name) + ' - ' + numeral


class ColumnFile(BaseModel):
    name = models.CharField(max_length=255)
    code = models.CharField(max_length=255, null=True, blank=True, unique=True)
    type = models.CharField(max_length=255, choices=(('string', 'String'), ('number', 'Number'), (
        'date', 'Date'), ('file', 'File'), ('decimal', 'Decimal')), default='string')
    format = models.CharField(max_length=255, null=True, blank=True)
    regex = models.CharField(max_length=255, null=True, blank=True)
    value = models.TextField(default='')
    objects = models.Manager()

    def save(self, *args, **kwargs):
        if not self.code:
            self.code = unique_code_generator(self)
        super(ColumnFile, self).save(*args, **kwargs)

    class Meta:
        verbose_name = 'Columna de Plantilla de Archivo'
        verbose_name_plural = 'Columnas de Plantilla de Archivo'

    def __str__(self):
        return str(self.name)


class StatusNumeral(models.TextChoices):
    APROVED = 'aproved', 'Aprobado'
    REJECTED = 'rejected', 'Rechazado'
    INGRESS = 'ingress', 'Ingresado'


class TransparencyActive(BaseModel):
    establishment = models.ForeignKey(
        'EstablishmentExtended', on_delete=models.CASCADE, related_name='transparency_active')
    numeral = models.ForeignKey(
        'Numeral', on_delete=models.CASCADE, related_name='transparency_active')
    files = models.ManyToManyField(
        'FilePublication', related_name='transparency_active', blank=True)
    slug = models.SlugField(max_length=255, null=True,
                            blank=True, unique=True, editable=False, db_index=True)
    month = models.IntegerField()
    year = models.IntegerField()
    status = models.CharField(max_length=255,
                              choices=(('aproved', 'Aprobado'), ('rejected', 'Rechazado'), ('ingress', 'Ingresado')), default=StatusNumeral.INGRESS)

    published = models.BooleanField(default=False)
    published_at = models.DateTimeField(null=True, blank=True)
    max_date_to_publish = models.DateTimeField(null=True, blank=True)

    objects = models.Manager()

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = str(self.month) + '-' + str(self.year) + '-' + \
                unique_slug_generator(self.establishment)

            self.slug = unique_slug_generator(self, self.slug)

        super(TransparencyActive, self).save(*args, **kwargs)

    class Meta:
        verbose_name = 'Transparencia Activa'
        verbose_name_plural = 'Transparencias Activas'

        unique_together = ('establishment', 'numeral', 'month', 'year')
