from typing import Any
from entity_app.domain.services.solicity_service import SolicityService
from entity_app.adapters.impl.solicity_impl import SolicityImpl
from rest_framework.generics import ListAPIView
from  rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from entity_app.adapters.serializers import SolicitySerializer, SolicityResponseSerializer
from entity_app.utils.permissions import HasPermission
from entity_app.utils.pagination import StandardResultsSetPagination, StandardResultsSetPaginationDicts
import openpyxl
from openpyxl.utils import get_column_letter
from django.http import HttpResponse

from entity_app.domain.models.solicity import Status
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entity_app.adapters.impl.transparency_active_impl import TransparencyActiveImpl
from entity_app.adapters.impl.transparency_colaborative_impl import TransparencyColaborativeImpl
from entity_app.adapters.impl.transparency_focus_impl import TransparencyFocalImpl
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.domain.services.transparency_active_service import TransparencyActiveService
from entity_app.domain.services.transparency_colaborative_service import TransparencyColaborativeService
from entity_app.domain.services.transparency_focus_service import TransparencyFocusService
from entity_app.domain.services.report_service import ReportService
from datetime import datetime
from rest_framework.pagination import PageNumberPagination

   
   
class ArchivosSubidos(APIView):
    
    
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicityresponse'
    output_serializer_class = SolicityResponseSerializer
    
    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self.solicity_service = SolicityService(SolicityImpl())
        self.transparency_service = TransparencyActiveService(TransparencyActiveImpl())
        self.numera_service = NumeralService(NumeralImpl())
        self.transparency_collab = TransparencyColaborativeService(TransparencyColaborativeImpl())
        self.transparency_focus = TransparencyFocusService(TransparencyFocalImpl())

        self.report_service = ReportService(self.solicity_service, self.transparency_service, self.numera_service, self.transparency_collab, self.transparency_focus)
        
        
        
        
    def get(self, request):
        
        establishment_id = request.query_params.get('establishment_id', None)
        year = request.query_params.get('year', None)
        
        if establishment_id is None:
            raise ValueError('Debe seleccionar un establecimiento')
        if year is None:
            year = datetime.now().year
        
        ta = self.transparency_service.get_by_year(year, establishment_id)
        tc = self.transparency_collab.get_by_year(year, establishment_id)
        tf = self.transparency_focus.get_by_year(year, establishment_id)
        
        list_final = []
        print(ta )
        for row_num, row_data in enumerate(ta):
            for i in row_data.files.all():
                _row_data = {
                    'index': row_num,
                    'mes': row_data.month,
                    'tipo': 'Activa',
                    'descripcion': row_data.numeral.description,
                    'enlace': i.relative_url
                }

                list_final.append(_row_data)

        for row_num, row_data in enumerate(tc):
            for i in row_data.files.all():
                _row_data = {
                    'index': row_num,
                    'mes': row_data.month,
                    'tipo': 'Colaborativa',
                    'descripcion': 'Colaborativa',
                    'enlace': i.relative_url
                }

                list_final.append(_row_data)
                
                
        for row_num, row_data in enumerate(tf):
            for i in row_data.files.all():
                _row_data = {
                    'index': row_num,
                    'mes': row_data.month,
                    'tipo': 'Focalizada',
                    'descripcion': 'Focalizada',
                    'enlace': i.relative_url
                }

                list_final.append(_row_data)
                
        paginator = StandardResultsSetPaginationDicts()
        paginator.page_size = 10  # Puedes ajustar el tamaño de la página aquí
        paginated_list = paginator.paginate_queryset(list_final, request)

        # Retornar la respuesta paginada
        return paginator.get_paginated_response(paginated_list)
        
        
        
        


class ReporteSolicitudes(APIView):
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicityresponse'
    output_serializer_class = SolicityResponseSerializer
    
    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self.solicity_service = SolicityService(SolicityImpl())
        self.transparency_service = TransparencyActiveService(
            TransparencyActiveImpl())
        self.numera_service = NumeralService(NumeralImpl())
        self.transparency_collab = TransparencyColaborativeService(
            TransparencyColaborativeImpl())
        self.transparency_focus = TransparencyFocusService(
            TransparencyFocalImpl())

        self.report_service = ReportService(self.solicity_service, self.transparency_service,
                                            self.numera_service, self.transparency_collab, self.transparency_focus)



    def post(self, request):
        year = request.data.get('year', None)

        if year is None:
            year = datetime.now().year
            

        
        value = self.report_service.generate_solicity_receiver(request.user.id, year)

        
        #return file
        response = HttpResponse(value, content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        response['Content-Disposition'] = 'attachment; filename="SolicitudesRecibidas.xlsx"'
        return response


class ReporteNoRespuestas(ListAPIView):
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicityresponse'
    output_serializer_class = SolicityResponseSerializer

    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self.solicity_service = SolicityService(SolicityImpl())
        self.transparency_service = TransparencyActiveService(
            TransparencyActiveImpl())
        self.numera_service = NumeralService(NumeralImpl())
        self.transparency_collab = TransparencyColaborativeService(
            TransparencyColaborativeImpl())
        self.transparency_focus = TransparencyFocusService(
            TransparencyFocalImpl())

        self.report_service = ReportService(self.solicity_service, self.transparency_service,
                                            self.numera_service, self.transparency_collab, self.transparency_focus)

    def post(self, request):
        year = request.data.get('year', None)

        if year is None:
            year = datetime.now().year

        value = self.report_service.generate_solicities_not_response(request.user.id, year)

        # return file
        response = HttpResponse(
            value, content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        response['Content-Disposition'] = 'attachment; filename="SolicitudesRecibidas.xlsx"'
        return response


class ReporteRespuestas(ListAPIView):
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicityresponse'
    output_serializer_class = SolicityResponseSerializer
    
    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self.solicity_service = SolicityService(SolicityImpl())
        self.transparency_service = TransparencyActiveService(
            TransparencyActiveImpl())
        self.numera_service = NumeralService(NumeralImpl())
        self.transparency_collab = TransparencyColaborativeService(
            TransparencyColaborativeImpl())
        self.transparency_focus = TransparencyFocusService(
            TransparencyFocalImpl())

        self.report_service = ReportService(self.solicity_service, self.transparency_service,
                                            self.numera_service, self.transparency_collab, self.transparency_focus)



    
    def post(self, request):
        year = request.data.get('year', None)

        if year is None:
            year = datetime.now().year
            

        
        value = self.report_service.generate_solicities_response(request.user.id, year)

        
        #return file
        response = HttpResponse(
            value, content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        response['Content-Disposition'] = 'attachment; filename="SolicitudesRecibidas.xlsx"'
        return response




class ReporteArchivos(APIView):
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicityresponse'
    output_serializer_class = SolicityResponseSerializer
    
    def __init__(self, **kwargs: Any) -> None:
        super().__init__(**kwargs)
        self.solicity_service = SolicityService(SolicityImpl())
        self.transparency_service = TransparencyActiveService(
            TransparencyActiveImpl())
        self.numera_service = NumeralService(NumeralImpl())
        self.transparency_collab = TransparencyColaborativeService(
            TransparencyColaborativeImpl())
        self.transparency_focus = TransparencyFocusService(
            TransparencyFocalImpl())
        self.report_service = ReportService(self.solicity_service, self.transparency_service,
                                            self.numera_service, self.transparency_collab, self.transparency_focus)
        
        
    def post(self, request):
        establishment_id = request.data.get('establishment_id', None)
        year = request.data.get('year', None)

        if establishment_id is None:
            raise ValueError('Debe seleccionar un establecimiento')
        if year is None:
            year = datetime.now().year
            

        value = self.report_service.generate_trasparency_report(
            establishment_id, year)

        
        #return file
        response = HttpResponse(
            value, content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        response['Content-Disposition'] = 'attachment; filename="SolicitudesRecibidas.xlsx"'
        return response
        