from typing import Any
from rest_framework.views import APIView
from entity_app.adapters.serializers import NumeralResponseSerializer, NumeralDetailSerializer
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entity_app.utils.permissions import BelongsToEstablishment,NumeralIsOwner
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


class NumeralsByEstablishment(APIView):
    
    serializer_class = NumeralResponseSerializer
    
    permission_classes = [IsAuthenticated,BelongsToEstablishment]
    
    def __init__(self, **kwargs: Any) -> None:
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )
   
   
    @swagger_auto_schema(
        operation_description="Get all numerals by establishment",
        responses={200: NumeralResponseSerializer},
        manual_parameters=[
            openapi.Parameter('establishtment_id', openapi.IN_QUERY, type=openapi.TYPE_STRING, description="Establishtment id"),
        ]
    )
    def get(self, request):
        
        try:
            if not request.query_params.get('establishtment_id'):
                return Response({
                    'message': 'establishtment_id is required',
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json':{}
                }, status=status.HTTP_400_BAD_REQUEST)
            
            numerals = self.service.get_by_entity(request.query_params.get('establishtment_id'))
            
            serializer = self.serializer_class(numerals, many=True)
            
            return Response(serializer.data)
        
        except Exception as e:
            return Response({
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json':{}
            }, status=status.HTTP_400_BAD_REQUEST)
            
            
            
class NumeralDetail(APIView):
        
    serializer_class = NumeralDetailSerializer
    
    permission_classes = [IsAuthenticated,NumeralIsOwner]
     
    def __init__(self, **kwargs: Any) -> None:
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )
    
    
    @swagger_auto_schema(
        operation_description="Get numeral detail",
        responses={200: NumeralResponseSerializer},
        manual_parameters=[
            openapi.Parameter('numeral_id', openapi.IN_QUERY, type=openapi.TYPE_STRING, description="Numeral id"),
        ]
    )
    def get(self, request):
        
        try:
            if request.query_params.get('numeral_id') is None:
                return Response({
                    'message': 'numeral_id is required',
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json':{}
                }, status=status.HTTP_400_BAD_REQUEST)
            numeral = self.service.get(request.query_params.get('numeral_id'))
            
            serializer = self.serializer_class(numeral)
            
            return Response(serializer.data)
        
        except Exception as e:
            return Response({
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json':{}
            }, status=status.HTTP_400_BAD_REQUEST)
        