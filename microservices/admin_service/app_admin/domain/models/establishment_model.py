
from django.db import models

from app_admin.utils.function import unique_slug_generator
from .base_model import BaseModel


class UserEstablishment(BaseModel):
    user = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, null=True, blank=True)
    establishment = models.ForeignKey(
        'Establishment', on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Usuario por Institución'
        verbose_name_plural = 'Usuarios por Institución'


class TypeOrganization(BaseModel):
    name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Tipo de Organización'
        verbose_name_plural = 'Tipos de Organización'


class TypeInstitution(BaseModel):
    name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Tipo de Institución'
        verbose_name_plural = 'Tipos de Institución'


class FunctionOrganization(BaseModel):
    name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Función de Organización'
        verbose_name_plural = 'Funciones de Organización'


class Establishment(BaseModel):

    name = models.CharField(max_length=255,db_index=True)
    identification = models.CharField(
        max_length=255, unique=True, null=True, blank=True,db_index=True)
    alias = models.CharField(max_length=255, null=True, blank=True)
    code = models.CharField(max_length=255, null=True, blank=True, unique=True,db_index=True)
    abbreviation = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    type_organization = models.ForeignKey(
        TypeOrganization, on_delete=models.CASCADE, null=True, blank=True)
    function_organization = models.ForeignKey(
        FunctionOrganization, on_delete=models.CASCADE, null=True, blank=True)
    type_institution = models.ForeignKey(
        TypeInstitution, on_delete=models.CASCADE, null=True, blank=True,db_index=True)
    logo = models.ImageField(upload_to='establishment')
    highest_authority = models.CharField(max_length=255)
    first_name_authority = models.CharField(max_length=255)
    last_name_authority = models.CharField(max_length=255)
    job_authority = models.CharField(max_length=255)
    email_authority = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    slug = models.SlugField(max_length=255, null=True, blank=True, unique=True,db_index=True)

    visits = models.IntegerField(default=0)

    class Meta:
        verbose_name = 'Institución'
        verbose_name_plural = 'Instituciones'

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = unique_slug_generator(self)
        super(Establishment, self).save(*args, **kwargs)

    def update(self, *args, **kwargs):
        self.slug = unique_slug_generator(self)
        super(Establishment, self).save(*args, **kwargs)
    # generate code secuence

    # permisos personalizados


class LawEnforcement(BaseModel):

    highest_committe = models.CharField(max_length=255)
    first_name_committe = models.CharField(max_length=255)
    last_name_committe = models.CharField(max_length=255)
    job_committe = models.CharField(max_length=255)
    email_committe = models.CharField(max_length=255)
    establishment = models.ManyToManyField(
        Establishment, related_name='lawenforcement_set')
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:

        verbose_name = 'Comité de Transparencia'
        verbose_name_plural = 'Comités de Transparencia'


class AccessToInformation(BaseModel):
    email = models.CharField(max_length=255)
    establishment = models.ManyToManyField(
        Establishment, related_name='accesstoinformation_set')
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:
        verbose_name = 'Acceso a la Información'
        verbose_name_plural = 'Accesos a la Información'
