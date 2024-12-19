from entity_app.adapters.serializers import AnualReportCreateSerializer
from rest_framework.views import APIView
from entity_app.domain.services.anual_report_service import AnualReportService
from entity_app.adapters.impl.anual_report_impl import AnualReportImpl
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.permissions import HasPermission
from rest_framework.response import Response


class AnualReportView(APIView):
    serializer_class = AnualReportCreateSerializer
    permission_classes = [IsAuthenticated, HasPermission]
    
    
    def __init__(self, *args, **kwargs):
        self.service = AnualReportService(AnualReportImpl())

    
    def post(self, request):
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        self.service.create(**data.validated_data)
        return Response(status=201)
    

    def get(self, request):
        establishment_id = request.query_params.get('establishment_id')
        year = request.query_params.get('year')
        month = request.query_params.get('month')
        if establishment_id is None or year is None or month is None:
            return Response(status=400)
        
        anual_reports = self.service.get(establishment_id, year, month)
        return Response(anual_reports)

    