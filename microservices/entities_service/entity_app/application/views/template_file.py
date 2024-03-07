
from typing import Any
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from entity_app.adapters.serializers import TemplateFileValidateSerializer
from entity_app.domain.services.template_service import TemplateService
from entity_app.adapters.impl.template_file_impl import TemplateFileImpl
from drf_yasg.utils import swagger_auto_schema




class TemplateFileValidate(APIView):
    
    permission_classes = (IsAuthenticated,)
    parser_classes = (MultiPartParser, FormParser)
    serializer_class = TemplateFileValidateSerializer

    
    def __init__(self, **kwargs: Any) -> None:
        self.service = TemplateService(
            template_repo=TemplateFileImpl()
        )
    
    @swagger_auto_schema(
        operation_description="Endpoint to validate a file",
        request_body=TemplateFileValidateSerializer,
        responses={200: TemplateFileValidateSerializer},
        
    )
    def post(self, request):
        
        try:
            serializer = self.serializer_class(data=request.data)
            if serializer.is_valid():
                result = self.service.validate_file(serializer.validated_data['template_id'], serializer.validated_data['file'])
                return Response(
                    {
                        'message': 'Archivo validado',
                        'status': status.HTTP_200_OK,
                        'json': result
                    },
                    status=status.HTTP_200_OK)
            return Response(
                {
                    'message': serializer.errors,
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json': {}
                },
                status=status.HTTP_400_BAD_REQUEST)
        except ValueError as e:
            return Response({
                'message': str(e),
                'status': status.HTTP_409_CONFLICT,
                'json': {}
                
                }, status=status.HTTP_409_CONFLICT)
            
        