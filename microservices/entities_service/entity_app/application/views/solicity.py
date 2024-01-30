from typing import Any
from rest_framework.views import APIView

from entity_app.adapters.serializers import CreateExtensionSerializer
from entity_app.adapters.impl.solicity_impl import SolicityImpl
from entity_app.domain.services.solicity import SolicityService
from rest_framework.response import Response
from rest_framework import status



class CreateExtensionSolicityView(APIView):
    
    serializer_class = CreateExtensionSerializer
    
  
    def __init__(self, **kwargs: Any):
        self.service = SolicityService(solicity_repository=SolicityImpl())
        
        
    def post(self, request):
        try:
            serializer = self.serializer_class(data=request.data)
            serializer.is_valid(raise_exception=True)
            user_id = request.user.id
            response = self.service.create_extencion_solicity(
                motive=serializer.validated_data['motive'],
                solicity_id=serializer.validated_data['solicity_id'],
                user_id=user_id
            )
            return Response(response, status=status.HTTP_201_CREATED)
        except Exception as e:
            data = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }
            
            return Response(data, status=status.HTTP_400_BAD_REQUEST)
        
        
        
