from entity_app.adapters.serializers import AnualReportCreateSerializer, AnualReportSerializer, ListTransparencyColaborative, ListTransparencyFocus, TransparencyActiveListSerializer
from rest_framework.views import APIView
from entity_app.domain.services.anual_report_service import AnualReportService
from entity_app.adapters.impl.anual_report_impl import AnualReportImpl
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.permissions import HasPermission
from rest_framework.response import Response
from rest_framework.generics import ListAPIView

from entity_app.adapters.impl.solicity_impl import SolicityImpl
from entity_app.domain.services.solicity_service import SolicityService
from datetime import datetime

from entity_app.adapters.impl.transparency_active_impl import TransparencyActiveImpl
from entity_app.domain.services.transparency_active_service import TransparencyActiveService
from entity_app.adapters.impl.transparency_focus_impl import TransparencyFocalImpl
from entity_app.domain.services.transparency_focus_service import TransparencyFocusService
from entity_app.utils.pagination import StandardResultsSetPagination
from entity_app.adapters.impl.transparency_colaborative_impl import TransparencyColaborativeImpl
from entity_app.domain.services.transparency_colaborative_service import TransparencyColaborativeService
from shared.tasks.anual_report import generate_anual_report
from rest_framework import status
from entities_service.celery import app
class AnualReportView(APIView):
    serializer_class = AnualReportCreateSerializer
    permission_classes = [IsAuthenticated, HasPermission]
    
    permission_required = 'view_transparencyactive'

    def __init__(self, *args, **kwargs):
        self.service = AnualReportService(AnualReportImpl())

    
    def post(self, request):
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        res = self.service.create(data.validated_data)
        return Response(AnualReportSerializer(res).data,status=201)
    

    def get(self, request):
        establishment_id = request.query_params.get('establishment_id')
        year = request.query_params.get('year')
        month = request.query_params.get('month')
        if establishment_id is None or year is None or month is None:
            return Response(status=400)
        
        anual_reports = self.service.get(establishment_id, year, month)
        return Response(AnualReportSerializer(anual_reports).data)

    
    
class AnualReportSolicityStats(APIView):
    
    permission_classes = [IsAuthenticated, HasPermission]

    permission_required = 'view_transparencyactive'

    def __init__(self, *args, **kwargs):
        self.service = SolicityService(SolicityImpl())
    
    def get(self,request):
        
        establisment_id = request.query_params.get('establisment_id',0)
        if establisment_id==0:
            return Response({'message':'la institución es incorrecta'},400)
        year = datetime.now().year
        
        total = self.service.total_saip_in_year(
            establisment_id=establisment_id,
            year=year
        )
        
        total_response_to_10_days = self.service.total_response_to_10_days(
            year,
           establisment_id, 

        )
        
        percent_response_to_10_days = self.service.calculate_percentage(total_response_to_10_days,total)
        
        total_reponse_to_11_days = self.service.total_reponse_to_11_days(
            year,
            establisment_id,
        )
        percent_reponse_to_11_days  = self.service.calculate_percentage(
            total_reponse_to_11_days, total)

        
        total_response_plus_15_days = self.service.total_response_plus_15_days(
            year,
            establisment_id,
        )
        
        percent_response_plus_15_days = self.service.calculate_percentage(
            total_response_plus_15_days, total)

        total_no_response = self.service.total_no_responsed(
            year, establisment_id)


        percent_no_response = self.service.calculate_percentage(total_no_response,total)
        return Response({
            'total': total,
            'total_response_to_10_days': total_response_to_10_days,
            'percent_response_to_10_days':percent_response_to_10_days,
            'total_reponse_to_11_days': total_reponse_to_11_days,
            'percent_reponse_to_11_days': percent_reponse_to_11_days,
            'total_response_plus_15_days': total_response_plus_15_days,
            'percent_response_plus_15_days': percent_response_plus_15_days,
            'total_no_response': total_no_response,
            'percent_no_response': percent_no_response
        })
        
        
class AnualReportTA(ListAPIView):
    permission_classes = [IsAuthenticated, HasPermission]

    pagination_class = StandardResultsSetPagination
    permission_required = 'view_transparencyactive'
    serializer_class = TransparencyActiveListSerializer
    def __init__(self, **kwargs):
        self.service =TransparencyActiveService(TransparencyActiveImpl())
        
        
    def get(self, request):
        
        establishment_id = request.query_params.get('establishment_id',0)
        is_default = request.query_params.get('is_default',1)
        year = datetime.now().year
        if establishment_id == 0:
            return Response({'message': 'la institución es incorrecta'}, 400)
        
        queryset = self.service.get_by_year(year, establishment_id).filter(
            numeral__is_default=is_default
        )
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


class AnualReportTF(ListAPIView):
    permission_classes = [IsAuthenticated, HasPermission]

    pagination_class = StandardResultsSetPagination
    permission_required = 'view_transparencyactive'
    serializer_class = ListTransparencyFocus
    
    def __init__(self, **kwargs):
        self.service =TransparencyFocusService(TransparencyFocalImpl())
        
    def get(self, request):

        establishment_id = request.query_params.get('establishment_id', 0)
        year = datetime.now().year
        if establishment_id == 0:
            return Response({'message': 'la institución es incorrecta'}, 400)

        queryset = self.service.get_by_year_all(year, establishment_id)
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


class AnualReportTC(ListAPIView):
    permission_classes = [IsAuthenticated, HasPermission]

    pagination_class = StandardResultsSetPagination
    permission_required = 'view_transparencyactive'
    serializer_class = ListTransparencyColaborative

    def __init__(self, **kwargs):
        self.service = TransparencyColaborativeService(TransparencyColaborativeImpl())

    def get(self, request):

        establishment_id = request.query_params.get('establishment_id', 0)
        year = datetime.now().year
        if establishment_id == 0:
            return Response({'message': 'la institución es incorrecta'}, 400)

        queryset = self.service.get_by_year_all(year, establishment_id)
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


class AnualReportGenerate(APIView):
    
    permission_classes = []

    def get(self,request):
        year = request.query_params.get('year')
        
        if year is None:
            year = datetime.now().year
        task = generate_anual_report.delay(year)
        context = {
            'task_id': task.id,
            'task_status': task.status,
        }
        return Response(
            context,
            status=200
        )
   
    
class TaskView(APIView):
    permission_classes = []

    def get(self, request, task_id):
        task = app.AsyncResult(task_id)
        print(task)
        response_data = {'task_status': task.status, 'task_id': task.id,
                         'meta':task.info}

        if task.status == 'SUCCESS':
            response_data['results'] = task.get()
            return Response({'data': response_data}, status=status.HTTP_200_OK, headers={'Access-Control-Allow-Origin': '*'})
        elif task.status == 'FAILURE':
            return Response({'data': response_data}, status=status.HTTP_400_BAD_REQUEST, headers={'Access-Control-Allow-Origin': '*'})
        return Response({'data': response_data}, status=status.HTTP_202_ACCEPTED, headers={'Access-Control-Allow-Origin': '*'})
