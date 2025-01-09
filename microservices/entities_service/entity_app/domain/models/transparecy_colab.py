from django.db import models
from entity_app.domain.models.base_model import BaseModel
from entity_app.utils.functions import unique_slug_generator


class TransparencyColab(BaseModel):
    establishment = models.ForeignKey(
        'EstablishmentExtended', on_delete=models.CASCADE, related_name='transparency_colab')
    numeral = models.ForeignKey(
        'Numeral', on_delete=models.CASCADE, related_name='transparency_colab')
    files = models.ManyToManyField(
        'FilePublication', related_name='transparency_colab', blank=True)
    slug = models.SlugField(max_length=255, null=True,
                            blank=True, unique=True, editable=False, db_index=True)
    month = models.IntegerField(db_index=True)
    year = models.IntegerField(db_index=True)
    status = models.CharField(max_length=255,
                              choices=(('pending', 'Pendiente'),
                                       ('ingress', 'Ingresado'),), default='pending')

    published = models.BooleanField(default=False)
    published_at = models.DateTimeField(null=True, blank=True)
    max_date_to_publish = models.DateTimeField(null=True, blank=True)

    objects = models.Manager()

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = str(self.month) + '-' + str(self.year) + '-' + \
                self.establishment.name
            self.slug = unique_slug_generator(self,self.slug)
            
        super(TransparencyColab, self).save(*args, **kwargs)

    class Meta:
        verbose_name = 'Transparencia Colaborativa'
        verbose_name_plural = 'Transparencias Colaborativa'
