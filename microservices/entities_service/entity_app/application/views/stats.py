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

        top_20_most_visited = EstablishmentExtended.get_top_20_most_visited()

        #

        response = {
            'entites_total': establishments,
            'solicities': {
                'recibidas': recibidas_list,
                'atendidas': atentidas_list
            },
            'top_20_most_visited': EstablishmentSerializer(top_20_most_visited, many=True).data


        }

        return Response(response, 200)


class EstablishmentStats(ListAPIView):
    permission_classes = []
    pagination_class = StandardResultsSetPaginationDicts

    def get(self, request, *args, **kwargs):
        year = request.query_params.get('year', datetime.now().year)
        month = request.query_params.get('month', datetime.now().month)
        top_20_establishments = EstablishmentExtended.get_top_20_best(year)

        data = [{'establishment': est, 'score': score,
                 'recibidas': recibidas,
                 'atendidas': atendidas,
                 'prorrogas': prorrogas,
                 'insistencias': insistencias,
                 'no_respuestas': no_respuestas}
                for est, score, recibidas, atendidas, prorrogas, insistencias, no_respuestas in top_20_establishments]

        # Serializar los datos
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

    def calculate_publishing_score(self, establishment_id, year):
        current_year = year
        score = 0

        publications = TransparencyActive.objects.filter(
            establishment_id=establishment_id,
            year=current_year,
            published=True,
            published_at__lte=datetime.now()
        )

        for publication in publications:
            published_day = publication.published_at.day
            if 1 <= published_day <= 4:
                score += 5 - published_day  # Más cerca al día 1, más puntaje

        return score

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

        score = self.calculate_publishing_score(establishment, year)
        score_saip = 0
        total_recibidas = sum(recibidas_list)
        total_atendidas = sum(atentidas_list)
        if total_recibidas == 0:
            score_saip = 0
        else:
            score_saip = total_atendidas / total_recibidas
            score_saip = score_saip * 100
            score_saip = round(score_saip, 2)

        total_score = score + score_saip
        if score_saip != 0 and score != 0:
            total_score = total_score / 2
        else:
            total_score = score_saip if score_saip != 0 else score

        total_score = round(total_score, 2)
        data = {
            "recibidas": recibidas_list,
            "atendidas": atentidas_list,
            "total_recibidas": sum(recibidas_list),
            "total_atendidas": sum(atentidas_list),
            "score_activa": score,
            "score_saip": score_saip,
            "total_score": total_score,
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

        month = request.query_params.get('month', 0)
        year = request.query_params.get('year', 0)

        establishments = self.get_queryset()

        data = EstablishmentcomplianceSerializer(establishments, context={
            'month': month, 'year': year})

        paginator = self.pagination_class()
        paginated_data = paginator.paginate_queryset(data.data, request)

        return paginator.get_paginated_response(paginated_data)
