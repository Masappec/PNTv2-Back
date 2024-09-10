from entity_app.domain.models import Solicity, Status, TimeLineSolicity, TransparencyActive, \
    EstablishmentExtended, FilePublication
from rest_framework.views import APIView
from datetime import datetime
from rest_framework.response import Response
from django.contrib.auth.models import User
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from entity_app.adapters.serializers import EstablishmentSerializer, EstablishmentScoreSerializer, EstablishmentcomplianceSerializer, MessageTransactional
from entity_app.utils.pagination import StandardResultsSetPaginationDicts
from rest_framework.generics import ListAPIView
from django.db.models import Q
from django.db.models import Count
from django.db.models.functions import ExtractDay
from django.db.models import F, Avg, ExpressionWrapper, DurationField
from django.utils.timezone import now
from django.db.models.functions import Round
class StatsCitizen(APIView):

    permission_classes = []

    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('year', openapi.IN_QUERY,
                              type=openapi.TYPE_STRING),

        ]
    )
    def get(self, request):

        year = request.query_params.get('year', datetime.now().year)
        month = request.query_params.get('month', datetime.now().month)
        establishments = EstablishmentExtended.objects.active_transparency_stats(
            year, month)

        atentidas_list = []
        recibidas_list = []
        timeline = TimeLineSolicity.objects.all()
        for i in range(1, 13):
            if year:
                recibidas = timeline.filter(status=Status.SEND,
                                            created_at__month=i, created_at__year=year).count()
                atendidas = timeline.filter(created_at__month=i, created_at__year=year,
                                            status__in=[Status.RESPONSED]).count()

            else:
                recibidas = timeline.filter(
                    status=Status.SEND, created_at__month=i).count()
                atendidas = timeline.filter(created_at__month=i,
                                            status__in=[Status.RESPONSED, Status.INSISTENCY_RESPONSED]).count()

            recibidas_list.append(recibidas)

            atentidas_list.append(atendidas)


        #

        response = {
            'entites_total': establishments,
            'solicities': {
                'recibidas': recibidas_list,
                'atendidas': atentidas_list
            },


        }

        return Response(response, 200)


class EstablishmentStats(ListAPIView):
    permission_classes = []
    pagination_class = StandardResultsSetPaginationDicts

    def get(self, request, *args, **kwargs):
        search = request.query_params.get('search', None)
        sort = request.query_params.get('sort[]', None)
        year = datetime.now().year
        month = datetime.now().month

        query_set = EstablishmentExtended.objects.filter(is_active=True)

        if search:
            query_set = query_set.filter(name__icontains=search)
        if sort:
            query_set = query_set.order_by(sort)

        # Anotaciones para calcular totales y puntuaciones
        query_set = query_set.annotate(
            total_TA=Count('numerals'),
            total_TP=Count('transparency_active', filter=Q(transparency_active__year=year,
                           transparency_active__month=month, transparency_active__published_at__day__lte=5)),
            total_TS=Count('solicity', filter=Q(solicity__date__year=year,
                           solicity__date__month=month) & ~Q(solicity__status=Status.DRAFT)),
            total_TR=Count('solicity__timelinesolicity', filter=Q(
                solicity__timelinesolicity__status=Status.RESPONSED)),
            total_TSP=Count('solicity__timelinesolicity', filter=Q(
                solicity__timelinesolicity__status=Status.PRORROGA)),
            total_TSI=Count('solicity__timelinesolicity', filter=Q(
                solicity__timelinesolicity__status=Status.INSISTENCY_SEND)),
            total_TSN=Count('solicity__timelinesolicity', filter=Q(
                solicity__timelinesolicity__status=Status.NO_RESPONSED)),
            total_TF=Count('transparency_focal', filter=Q(transparency_focal__year=year,
                           transparency_focal__month=month, transparency_focal__published_at__day__lte=5)),
            total_TC=Count('transparency_colab', filter=Q(transparency_colab__year=year,
                           transparency_colab__month=month, transparency_colab__published_at__day__lte=5))
        )

        # Calcular el puntaje para cada establecimiento
        data = [
            {
                'establishment': est,
                'total_recibidas': est.total_TS,
                'total_atendidas': est.total_TR,
                'total_prorroga': est.total_TSP,
                'total_insistencia': est.total_TSI,
                'total_no_respuesta': est.total_TSN,
                'score_saip': self.calculate_score(est)
            }
            for est in query_set
        ]

        serializer = EstablishmentScoreSerializer(data, many=True)

        # Obtener el paginador y paginar los datos
        paginator = self.pagination_class()
        paginated_data = paginator.paginate_queryset(serializer.data, request)

        return paginator.get_paginated_response(paginated_data)

    def calculate_score(self, est):
        # Safeguard against division by zero
        if est.total_TA != 0 and est.total_TS != 0:
            score = ((est.total_TP * 100) / est.total_TA) * 50 + \
                    ((est.total_TR * 100) / est.total_TS) * 50
        else:
            score = 0

        if est.total_TC > 0:
            score *= 1.05
        if est.total_TF > 0:
            score *= 1.05

        return score

class IndicatorsEstablishmentView(APIView):
    permission_classes = []

    def count_published_months(self, establishment_id, year):
        current_year = datetime.now().year
        published_months = TransparencyActive.objects.filter(
            establishment_id=establishment_id,
            year=current_year,
            published=True,
            published_at__lte=datetime.now()
        ).dates('published_at', 'month', order='ASC').distinct().count()
        return published_months

    def _calculate_publishing_score(self, establishment_id, year):

        return EstablishmentExtended.objects.get(id=establishment_id).calculate_publishing_score(year)

    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('year', openapi.IN_QUERY,
                              type=openapi.TYPE_STRING),
            openapi.Parameter('establishment_id',
                              openapi.IN_QUERY, type=openapi.TYPE_STRING),
        ]
    )
    def get(self, request):
        atentidas_list = []
        recibidas_list = []
        year = request.query_params.get('year', None)
        establishment = request.query_params.get('establishment_id', None)
        timeline = TimeLineSolicity.objects.all()
        for i in range(1, 13):
            if year:
                recibidas = timeline.filter(status=Status.SEND,
                                            created_at__month=i, created_at__year=year,
                                            solicity__establishment_id=establishment).count()
                atendidas = timeline.filter(created_at__month=i, created_at__year=year,
                                            status__in=[Status.RESPONSED], solicity__establishment_id=establishment).count()

            else:
                recibidas = timeline.filter(
                    status=Status.SEND, created_at__month=i, solicity__establishment_id=establishment).count()
                atendidas = timeline.filter(created_at__month=i,
                                            status__in=[Status.RESPONSED, Status.INSISTENCY_RESPONSED], solicity__establishment_id=establishment).count()

            recibidas_list.append(recibidas)

            atentidas_list.append(atendidas)

        score = self._calculate_publishing_score(establishment, year)
        published_transparency = TransparencyActive.objects.filter(
            published=True,                         # Solo considerar los registros publicados
            published_at__year=year,
            establishment_id=establishment# Filtrar por el año 2024
        )


        # Contar la cantidad total de archivos (files) asociados a esos registros
        total_files = sum(t.files.count() for t in published_transparency)
       # Agrupar por el día del mes y contar las publicaciones
        most_frequent_day = TransparencyActive.objects.filter(
            published=True,  # Solo considerar los registros publicados
            published_at__isnull=False, # Asegurarse de que la fecha de publicación exista
            establishment_id=establishment  # Filtrar por el año 2024

        ).annotate(
            # Extraer el día del campo published_at
            day_of_publication=ExtractDay('published_at')
        ).values(
            'day_of_publication'  # Agrupar por día
        ).annotate(
            # Contar la frecuencia de cada día
            day_count=Count('day_of_publication')
        ).order_by('-day_count')  # Ordenar por la frecuencia, descendente
        

        # Filtrar los registros con el estado requerido y calcular la diferencia de tiempo
        time_deltas = TimeLineSolicity.objects.filter(
            # Ajusta según los nombres en tu sistema
            status__in=[Status.SEND, Status.RESPONSED]
        ).annotate(
            time_diff=ExpressionWrapper(
                # Diferencia entre la fecha de respuesta y la de recepción
                F('updated_at') - F('created_at'),
                output_field=DurationField()  # Resultado en duración
            )
        )

        # Calcular el promedio de la duración en segundos
        average_response_time = time_deltas.aggregate(average=Avg('time_diff'))

        # Obtener el promedio en segundos
        average_seconds = average_response_time['average'].total_seconds(
        ) if average_response_time['average'] else 0
        average_days = round(average_seconds / (60 * 60 * 24), 2)  # Convertir a días y redondear a 2 decimales
       
        FilePublication.objects.filter()
        
        data = {
            "recibidas": recibidas_list,
            "atendidas": atentidas_list,
            "total_recibidas": sum(recibidas_list),
            "total_atendidas": sum(atentidas_list),
            "score_activa": score['score_saip'],
            "score_saip": score['score_saip'],
            "total_score": score['score_saip'],
            "ta_published": total_files,
            "day_frencuency_response": average_days,
            "day_frencuency_publish": most_frequent_day[0]['day_of_publication'] if most_frequent_day.__len__() > 0 else 0
            
        }

        return Response(data, status=200)


class CountFilesView(APIView):
    permission_classes = []

    def get(self, request):
        count = FilePublication.objects.filter(
            transparency_active__published=True,

        ).count()

        return Response({'count': count}, status=200)


class EstablishmentCompliance(ListAPIView):
    permission_classes = []
    pagination_class = StandardResultsSetPaginationDicts

    def get_queryset(self):
        month = self.request.query_params.get('month', datetime.now().month)
        year = self.request.query_params.get('year', datetime.now().year)

        queryset = EstablishmentExtended.objects.all()

        # Anotaciones para total_published_ta, total_solicities_res, etc.
        queryset = queryset.annotate(
            total_published_ta=Count('transparency_active', filter=Q(
                transparency_active__year=year, transparency_active__month=month)),
            total_numeral_ta=Count('numerals'),
            total_solicities_res=Count('solicity', filter=Q(solicity__created_at__year=year, solicity__created_at__month=month) &
                                       (Q(solicity__status=Status.RESPONSED) |
                                        Q(solicity__status=Status.INSISTENCY_RESPONSED) |
                                        Q(solicity__status=Status.INFORMAL_MANAGMENT_RESPONSED))),
            total_solicities_rec=Count('solicity', filter=Q(
                solicity__created_at__year=year, solicity__created_at__month=month)),
            total_tf=Count('transparency_focal', filter=Q(
                transparency_focal__created_at__year=year, transparency_focal__created_at__month=month)),
            total_tc=Count('transparency_colab', filter=Q(
                transparency_colab__created_at__year=year, transparency_colab__created_at__month=month)),
        )
        return queryset

    def get(self, request):
        month = request.query_params.get('month', datetime.now().month)
        year = request.query_params.get('year', datetime.now().year)
        search = request.query_params.get('search', None)
        establishments = self.get_queryset()

        if search:
            establishments = establishments.filter(name__icontains=search)

        paginator = self.pagination_class()
        paginated_data = paginator.paginate_queryset(establishments, request)

        serializer = EstablishmentcomplianceSerializer(
            paginated_data, context={'month': month, 'year': year}, many=True)
        return paginator.get_paginated_response(serializer.data)
