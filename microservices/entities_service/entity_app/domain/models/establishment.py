from django.db import models


class EstablishmentManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(is_active=True)
    
    
    
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
    
    
    class Meta:
        managed = False
        db_table = 'app_admin_establishment'

