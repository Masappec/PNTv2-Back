from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from entity_app.domain.services.total_archivos_service import TotalArchivosService

class TotalArchivosTransparenciaView(APIView):
    permission_classes = [AllowAny]
    def get(self, request):
        servicio_total_archivos = TotalArchivosService()
        respuesta = servicio_total_archivos.obtener_totales()
        return Response(respuesta)
