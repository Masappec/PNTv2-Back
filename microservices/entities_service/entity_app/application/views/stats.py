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
        search = request.query_params.get('search',None)
        sort = request.query_params.get('sort[]',None)
        query_set = EstablishmentExtended.objects.filter(is_active=True)

       

        if search:
            query_set = query_set.filter(name__icontains=search)
        if sort:
            query_set = query_set.order_by(sort)
            
        # Serializar los datos
        data = [{'establishment': est, **est.calculate_total_score(datetime.now().year)}
                for est in query_set]
       
        serializer = EstablishmentScoreSerializer(data, many=True)

        # Obtener el paginador y paginar los datos
        paginator = self.pagination_class()
        paginated_data = paginator.paginate_queryset(serializer.data, request)

        return paginator.get_paginated_response(paginated_data)


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
        return EstablishmentExtended.objects.all()

    def get(self, request):

        month = request.query_params.get('month', datetime.now().month)
        year = request.query_params.get('year', datetime.now().year)

        establishments = self.get_queryset()

        data = EstablishmentcomplianceSerializer(establishments, context={
            'month': month, 'year': year},many=True)

        paginator = self.pagination_class()
        paginated_data = paginator.paginate_queryset(data.data, request)

        return paginator.get_paginated_response(paginated_data)
