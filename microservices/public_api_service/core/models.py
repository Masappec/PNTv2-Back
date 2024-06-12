from mongoengine import Document, StringField, BooleanField, ListField, EmbeddedDocument, EmbeddedDocumentField
from django.db import models
class Metadata(EmbeddedDocument):
    filename = StringField(required=True)
    delimiter = StringField(default=",")
    quotechar = StringField(default="\"")
    escapechar = StringField(default="\\")
    has_header = BooleanField(default=True)
    columns = ListField(StringField())
    numeral = StringField(default="decimal")
    article = StringField(default="19")
    month = StringField(default="12")
    year = StringField(default="2019")
    establishment_identification = StringField(default="CNPJ")
    user_upload = StringField(default="user")
    date_upload = StringField(default="date")
    path = StringField(default="path")
    numeral_description = StringField(default="numeral")
    establishment_name = StringField(default="establishment")


class CSVData(Document):
    metadata = EmbeddedDocumentField(Metadata)
    data = ListField(ListField(StringField()))


class EstablishmentExtended(models.Model):
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
    slug = models.SlugField(max_length=255, null=True, blank=True, unique=True)
    identification = models.CharField(max_length=255, null=True, blank=True)
    objects = models.Manager()

    class Meta:
        managed = False
        db_table = 'app_admin_establishment'
        verbose_name = 'Institución'
        verbose_name_plural = 'Instituciones'


class EstablishmentNumeral(models.Model):
    establishment = models.ForeignKey(
        'EstablishmentExtended', on_delete=models.CASCADE, related_name='numerals')
    numeral = models.ForeignKey(
        'Numeral', on_delete=models.CASCADE, related_name='establishments')
    value = models.TextField()
 
    objects = models.Manager()

    class Meta:
        
        managed = False
        db_table = 'entity_app_establishmentnumeral'


class Numeral(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    templates = models.ManyToManyField(
        'TemplateFile', related_name='numerals', blank=True)
    parent = models.ForeignKey(
        'self', on_delete=models.CASCADE, related_name='children', null=True, blank=True)
    is_default = models.BooleanField(default=True)
    type_transparency = models.CharField(max_length=255, choices=(
        ('A', 'Activa'), ('P', 'Pasiva'), ('C', 'Colaborativa'), ('F', 'Focalizada')), default='A')
    objects = models.Manager()

    class Meta:
        verbose_name = 'Numeral'
        verbose_name_plural = 'Numerales'
        managed = False
        db_table = 'entity_app_numeral'
    def __str__(self):
        return str(self.name)
    

class FilePublication(BaseModel):

    name = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    url_download = models.FileField(
        upload_to='publications/', null=True, blank=True)
    is_active = models.BooleanField(default=True, null=True, blank=True)
    is_colab = models.BooleanField(default=False, null=True, blank=True)
    objects = models.Manager()
    file_join = models.ForeignKey(
        'FilePublication', on_delete=models.CASCADE, null=True, blank=True)

    class Meta:
        verbose_name = 'Archivo Publicación'
        verbose_name_plural = 'Archivo Publicaciones'
        managed = False
        db_table = 'entity_app_filepublication'
class TransparencyActive(models.Model):
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
                              choices=(('pending', 'Pendiente'),
                                       ('ingress', 'Ingresado'),), default='pending')

    published = models.BooleanField(default=False)
    published_at = models.DateTimeField(null=True, blank=True)
    max_date_to_publish = models.DateTimeField(null=True, blank=True)

    objects = models.Manager()


    class Meta:
        managed = False
        db_table = 'entity_app_transparencyactive'