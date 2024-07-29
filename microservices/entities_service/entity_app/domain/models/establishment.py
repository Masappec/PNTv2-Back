from django.db import models
from datetime import datetime
from entity_app.domain.models.base_model import BaseModel
from entity_app.domain.models.transparency_active import EstablishmentNumeral, TransparencyActive
from entity_app.domain.models.solicity import Status,TimeLineSolicity
from django.utils import timezone
from django.db import connection


class EstablishmentManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(is_active=True)


    
    def SQL_STATS_ACTIVE(self):
        return '''WITH EstablishmentExtended AS (
                    SELECT id 
                    FROM app_admin_establishment
                ), 
                TransparencyActiveSubidas AS (
                    SELECT * 
                    FROM entity_app_transparencyactive
                    WHERE establishment_id IN (SELECT id FROM EstablishmentExtended)
                    AND year = %s
                    AND month = %s
                    AND published = TRUE
                ), 
                EstablishmentNumeralCount AS (
                    SELECT establishment_id, COUNT(*) as count
                    FROM entity_app_establishmentnumeral
                    GROUP BY establishment_id
                ), 
                TransparenciasEntidadCount AS (
                    SELECT establishment_id, COUNT(*) as count
                    FROM entity_app_transparencyactive
                    WHERE year = %s
                    AND month = %s
                    AND published = TRUE
                    GROUP BY establishment_id
                ),
                TotalEntitiesWithUploads AS (
                    SELECT COUNT(DISTINCT establishment_id) as total_with_uploads
                    FROM TransparencyActiveSubidas
                )

                SELECT 
                    COUNT(*) as total,
                    SUM(
                        CASE 
                            WHEN COALESCE(EstablishmentNumeralCount.count, 0) = COALESCE(TransparenciasEntidadCount.count, 0) 
                            AND COALESCE(TransparenciasEntidadCount.count, 0) > 0
                            THEN 1 ELSE 0 
                        END
                    ) as updated,
                    SUM(
                        CASE 
                            WHEN TransparenciasEntidadCount.count IS NULL 
                            OR TransparenciasEntidadCount.count = 0
                            THEN 1 ELSE 0 
                        END
                    ) as not_updated,
                    (SELECT total_with_uploads FROM TotalEntitiesWithUploads) as nearly_updated
                FROM 
                    EstablishmentExtended
                LEFT JOIN 
                    EstablishmentNumeralCount 
                ON 
                    EstablishmentExtended.id = EstablishmentNumeralCount.establishment_id
                LEFT JOIN 
                    TransparenciasEntidadCount 
                ON 
                    EstablishmentExtended.id = TransparenciasEntidadCount.establishment_id'''
    def active_transparency_stats(self, year, month):
        
        total_establishments = 0
        total_updated = 0
        total_no_updated = 0

        # Execute the raw SQL query using Django's database connection
        with connection.cursor() as cursor:
            cursor.execute(self.SQL_STATS_ACTIVE(), [year, month, year, month])
            row = cursor.fetchone()

            if row:
                total_establishments = row[0]
                total_updated = row[1]
                total_no_updated = row[2]
                tota_near_updated = row[3]

        return {
            'total': total_establishments,
            'updated': total_updated,
            'not_updated': total_no_updated,
            'nearly_updated': tota_near_updated
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
        query = '''
           WITH RequestCounts AS (
                SELECT
                    EXTRACT(MONTH FROM created_at) AS month,
                    COUNT(CASE WHEN status IN ('RESPONSED', 'INSISTENCY_RESPONSED') THEN 1 END) AS atendidas,
                    COUNT(CASE WHEN status = 'PRORROGA' THEN 1 END) AS prorroga,
                    COUNT(CASE WHEN status IN ('INSISTENCY_PERIOD', 'INSISTENCY_SEND','PERIOD_INFORMAL_MANAGEMENT','INFORMAL_MANAGMENT_SEND') THEN 1 END) AS insistencia,
                    COUNT(CASE WHEN status IN ('NO_RESPONSED','INSISTENCY_NO_RESPONSED','INFORMAL_MANAGMENT_NO_RESPONSED','FINISHED_WITHOUT_RESPONSE') THEN 1 END) AS no_respuesta
                FROM
                    entity_app_solicity
                WHERE
                    establishment_id = %s
                    AND (1 IS NULL OR EXTRACT(YEAR FROM created_at) = %s)
                GROUP BY
                    EXTRACT(MONTH FROM created_at)
            ),
            Recibidas AS (
                SELECT
                    EXTRACT(MONTH FROM created_at) AS month,
                    COUNT(CASE WHEN status = 'SEND' THEN 1 END) AS recibidas
                FROM
                    entity_app_timelinesolicity
                WHERE
                    solicity_id IN (SELECT id from entity_app_solicity WHERE establishment_id=%s)
                    AND (1 IS NULL OR EXTRACT(YEAR FROM created_at) = %s)
                GROUP BY
                    EXTRACT(MONTH FROM created_at)
            )
            SELECT
                COALESCE(SUM(Recibidas.recibidas), 0) AS total_recibidas,
                COALESCE(SUM(RequestCounts.atendidas), 0) AS total_atendidas,
                COALESCE(SUM(RequestCounts.prorroga), 0) AS total_prorroga,
                COALESCE(SUM(RequestCounts.insistencia), 0) AS total_insistencia,
                COALESCE(SUM(RequestCounts.no_respuesta), 0) AS total_no_respuesta,
                CASE 
                    WHEN COALESCE(SUM(Recibidas.recibidas), 0) = 0 THEN 0
                    ELSE ROUND(
                        (COALESCE(SUM(RequestCounts.atendidas), 0)::NUMERIC / COALESCE(SUM(Recibidas.recibidas), 0)::NUMERIC) * 100,
                        2
                    )
                END AS score_saip
            FROM
                RequestCounts
            LEFT JOIN
                Recibidas
            ON
                RequestCounts.month = Recibidas.month;
        '''

        # Execute the raw SQL query using Django's database connection
        with connection.cursor() as cursor:
            cursor.execute(query, [self.pk, year, self.pk, year])
            row = cursor.fetchone()

            if row:
                total_recibidas = row[0]
                total_atendidas = row[1]
                total_prorroga = row[2]
                total_insistencia = row[3]
                total_no_respuesta = row[4]
                score = row[5]
                
            else:
                score = 0
                total_recibidas = 0
                total_atendidas = 0
                total_prorroga = 0
                total_insistencia = 0
                total_no_respuesta = 0
                

        return {
            'total_recibidas': total_recibidas,
            'total_atendidas': total_atendidas,
            'total_prorroga': total_prorroga,
            'total_insistencia': total_insistencia,
            'total_no_respuesta': total_no_respuesta,
            'score_saip': score
        }

    def calculate_saip_score(self, year):
        # Define the SQL query
        query = '''
        WITH RequestCounts AS (
            SELECT
                EXTRACT(MONTH FROM created_at) AS month,
                COUNT(CASE WHEN status = 'SEND' THEN 1 END) AS recibidas,
                COUNT(CASE WHEN status IN ('RESPONSED', 'INSISTENCY_RESPONSED') THEN 1 END) AS atendidas
            FROM
                entity_app_timelinesolicity
            WHERE
                solicity_id IN (
                    SELECT id FROM entity_app_solicity
                    WHERE establishment_id = %s
                )
                AND (%s IS NULL OR EXTRACT(YEAR FROM created_at) = %s)
            GROUP BY
                EXTRACT(MONTH FROM created_at)
        )
        SELECT
            COALESCE(SUM(recibidas), 0) AS total_recibidas,
            COALESCE(SUM(atendidas), 0) AS total_atendidas,
            CASE 
                WHEN COALESCE(SUM(recibidas), 0) = 0 THEN 0
                ELSE ROUND(
                    (COALESCE(SUM(atendidas), 0)::NUMERIC / COALESCE(SUM(recibidas), 0)::NUMERIC) * 100,
                    2
                )
            END AS score_saip
        FROM
            RequestCounts;
        '''

        # Execute the raw SQL query using Django's database connection
        with connection.cursor() as cursor:
            # Parameters for the query
            params = [self.pk]
            if year:
                params.append(year)
                params.append(year)
            else:
                params.append(None)

            cursor.execute(query, params)
            row = cursor.fetchone()

            if row:
                total_recibidas = row[0]
                total_atendidas = row[1]
                score_saip = row[2]
            else:
                total_recibidas = 0
                total_atendidas = 0
                score_saip = 0

        return score_saip

    def calculate_total_score(self, year):
        data = self.calculate_publishing_score(year)
        score_saip = self.calculate_saip_score(year)

            
        score = data.get('score_saip', 0)
        total_score = score + score_saip
        if score_saip != 0 and score != 0:
            total_score = total_score / 2
        else:
            total_score = score_saip if score_saip != 0 else score

        return {
            'total_recibidas': data.get('total_recibidas', 0),
            'total_atendidas': data.get('total_atendidas', 0),
            'total_prorroga': data.get('total_prorroga', 0),
            'total_insistencia': data.get('total_insistencia', 0),
            'total_no_respuesta': data.get('total_no_respuesta', 0),
            'score_activa': score,
            'score_saip': score_saip,
            'total_score': total_score
        }
    
    @classmethod
    def get_top_20_most_visited(cls):
        return cls.objects.all().order_by('-visits')[:20]
    @classmethod
    def get_top_20_best(cls, year):
        establishments = cls.objects.all()

        
        establishment_scores = []
        for establishment in establishments:
            total_score = establishment.calculate_total_score(year)
            establishment_scores.append((establishment, total_score['total_score'], total_score['total_recibidas'], total_score['total_atendidas'], total_score['total_prorroga'], total_score['total_insistencia'], total_score['total_no_respuesta']))

        # Ordena las entidades por su puntaje en orden descendente y obtiene las primeras 20
        top_20_establishments = sorted(establishment_scores, key=lambda x: x[1], reverse=True)

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
