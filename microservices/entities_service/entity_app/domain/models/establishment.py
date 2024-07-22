from django.db import models
from datetime import datetime
from entity_app.domain.models.base_model import BaseModel
from entity_app.domain.models.transparency_active import EstablishmentNumeral, TransparencyActive
from entity_app.domain.models.solicity import Status,TimeLineSolicity
class EstablishmentManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(is_active=True)


    def active_transparency_stats(self):
        current_month = datetime.now().month
        current_year = datetime.now().year

        establishments = EstablishmentExtended.objects.all()

        total_establishments = establishments.count()
        updated_count = EstablishmentNumeral.objects.all()
        

        transparencias_subidas = TransparencyActive.objects.filter(
            establishment_id__in=establishments,
            year=current_year,
            published=True,
            published_at__lte=datetime.now()
        )
        
        total_updated = 0
        total_no_updated = 0
        for establishment in establishments:
            
            establishment_numeral = updated_count.filter(
                establishment_id=establishment.id).count()
            transparencias_entidad = transparencias_subidas.filter(
                establishment_id=establishment, year=current_year, published=True,month=current_month).count()
            
            if establishment_numeral>0:
                if establishment_numeral == transparencias_entidad:
                    total_updated += 1
                else:
                    total_no_updated += 1
            else:
                total_no_updated += 1
        
        
        
        

        return {
            'total': total_establishments,
            'updated': total_updated,
            'not_updated': total_no_updated
        }
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
    objects = EstablishmentManager()
    visits = models.IntegerField(default=0)

    class Meta:
        managed = False
        db_table = 'app_admin_establishment'

        verbose_name = 'Institución'
        verbose_name_plural = 'Instituciones'

    def calculate_publishing_score(self, year):
        current_year = year
        score = 0

        publications = TransparencyActive.objects.filter(
            establishment_id=self.pk,
            year=current_year,
            published=True,
            published_at__lte=datetime.now()
        )

        for publication in publications:
            published_day = publication.published_at.day
            if 1 <= published_day <= 4:
                score += 5 - published_day  # Más cerca al día 1, más puntaje

        return score

    def calculate_saip_score(self, year):
        recibidas_list = []
        atentidas_list = []

        timeline = TimeLineSolicity.objects.all()
        for i in range(1, 13):
            if year:
                recibidas = timeline.filter(
                    status=Status.SEND,
                    created_at__month=i,
                    created_at__year=year,
                    solicity__establishment_id=self.pk
                ).count()
                atendidas = timeline.filter(
                    created_at__month=i,
                    created_at__year=year,
                    status__in=[Status.RESPONSED, Status.INSISTENCY_RESPONSED],
                    solicity__establishment_id=self.pk
                ).count()
            else:
                recibidas = timeline.filter(
                    status=Status.SEND,
                    created_at__month=i,
                    solicity__establishment_id=self.pk
                ).count()
                atendidas = timeline.filter(
                    created_at__month=i,
                    status__in=[Status.RESPONSED, Status.INSISTENCY_RESPONSED],
                    solicity__establishment_id=self.pk
                ).count()

            recibidas_list.append(recibidas)
            atentidas_list.append(atendidas)

        total_recibidas = sum(recibidas_list)
        total_atendidas = sum(atentidas_list)

        if total_recibidas == 0:
            score_saip = 0
        else:
            score_saip = total_atendidas / total_recibidas
            score_saip = score_saip * 100
            score_saip = round(score_saip, 2)

        return score_saip

    def calculate_total_score(self, year):
        score = self.calculate_publishing_score(year)
        score_saip = self.calculate_saip_score(year)

        total_score = score + score_saip
        if score_saip != 0 and score != 0:
            total_score = total_score / 2
        else:
            total_score = score_saip if score_saip != 0 else score

        return total_score
    
    @classmethod
    def get_top_20_most_visited(cls):
        return cls.objects.all().order_by('-visits')[:20]
    @classmethod
    def get_top_20_best(cls, year):
        establishments = cls.objects.all()

        establishment_scores = []
        for establishment in establishments:
            total_score = establishment.calculate_total_score(year)
            establishment_scores.append((establishment, total_score))

        # Ordena las entidades por su puntaje en orden descendente y obtiene las primeras 20
        top_20_establishments = sorted(establishment_scores, key=lambda x: x[1], reverse=True)[:20]

        return top_20_establishments

class UserEstablishmentExtended(BaseModel):
    user = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, null=True, blank=True)
    establishment = models.ForeignKey(
        'EstablishmentExtended', on_delete=models.CASCADE, null=True, blank=True)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()

    class Meta:
        managed = False
        db_table = 'app_admin_userestablishment'
        unique_together = (('user', 'establishment'),)
