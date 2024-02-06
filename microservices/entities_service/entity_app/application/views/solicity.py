from typing import Any
from rest_framework.views import APIView

from entity_app.adapters.serializers import CreateExtensionSerializer, SolicityResponseSerializer
from entity_app.adapters.impl.solicity_impl import SolicityImpl
from entity_app.domain.services.solicity import SolicityService
from rest_framework.response import Response
from rest_framework import status

from entity_app.utils.permissions import HasPermission, IsOwnerResponseSolicity
from rest_framework.permissions import IsAuthenticated



class CreateExtensionSolicityView(APIView):
    
    serializer_class = CreateExtensionSerializer
    permission_classes = [IsAuthenticated,HasPermission]
    permission_required = 'add_extension'
    
  
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
        
        
class CreateManualSolicity(APIView):
    serializer_class = CreateExtensionSerializer
    
    permission_classes = [IsAuthenticated,HasPermission]
    permission_required = 'add_manual_solicity'
    
    
    def __init__(self, **kwargs: Any):
        self.service = SolicityService(solicity_repository=SolicityImpl())
        
        
    def post(self, request):
        try:
            serializer = self.serializer_class(data=request.data)
            serializer.is_valid(raise_exception=True)
            user_id = request.user.id
            response = self.service.create_manual_solicity(
                establishment_id=serializer.validated_data['establishment_id'],
                expiry_date=serializer.validated_data['expiry_date'],
                text=serializer.validated_data['text'],
                title=serializer.validated_data['title'],
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
    
        
        
        

class DeleteSolicityResponse(APIView):
        
    permission_classes = [IsAuthenticated,HasPermission, IsOwnerResponseSolicity]
    permission_required = 'delete_solicity_response'
    
    def __init__(self, **kwargs: Any):
        self.service = SolicityService(solicity_repository=SolicityImpl())
        
        
    def delete(self, request, solicity_response_id):
        try:
            response = self.service.delete_solicity_response(
                solicity_response_id=solicity_response_id,
                user_id=request.user.id
            )
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            data = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }
            
            return Response(data, status=status.HTTP_400_BAD_REQUEST)



class UpdateSolicityResponse(APIView):
    serializer_class = SolicityResponseSerializer
    permission_classes = [IsAuthenticated,HasPermission, IsOwnerResponseSolicity]
    permission_required = 'change_solicity_response'
    
    def __init__(self, **kwargs: Any):
        self.service = SolicityService(solicity_repository=SolicityImpl())
        
        
    def put(self, request, solicity_response_id):
        try:
            serializer = self.serializer_class(data=request.data)
            serializer.is_valid(raise_exception=True)
            response = self.service.update_solicity_response(
                attachments=serializer.validated_data['attachments'],
                category_id=serializer.validated_data['category_id'],
                files=  serializer.validated_data['files'],
                solicity_response_id=solicity_response_id,
                text=serializer.validated_data['text'],
            )
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            data = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }
            
            return Response(data, status=status.HTTP_400_BAD_REQUEST)