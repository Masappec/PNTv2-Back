from entity_app.adapters.impl.transparency_colaborative_impl import TransparencyColaborativeImpl
from entity_app.domain.services.transparency_colaborative_service import TransparencyColaborativeService

from datetime import datetime

from entity_app.utils.permissions import HasPermission
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.pagination import StandardResultsSetPagination

from rest_framework.generics import ListAPIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from entity_app.adapters.serializers import TransparencyColaboratyCreate, MessageTransactional, ListTransparencyColaborative

class CreateTransparencyColaboraty(APIView):

    serializer_class = TransparencyColaboratyCreate
    permission_classes = [IsAuthenticated, HasPermission]

    def __init__(self, **kwargs):
        self.sevice = TransparencyColaborativeService(TransparencyColaborativeImpl())

    def post(self, request, *args, **kwargs):

        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)

        month = datetime.now().month
        year = datetime.now().year
        today = datetime.now()
        maxDatePublish = datetime.now() + datetime.timedelta(days=15)

        try:
            transparency_colaborative = self.service.createTransparencyColaborative(data.validated_data['establishment_id'], data.validated_data['numeral_id'], data.validated_data['files'], month, year, today, maxDatePublish)

            res = MessageTransactional(
                data={
                    'message': 'Publicacion creada correctamente',
                    'status': 201,
                    'json': self.output_serializer_class(transparency_colaborative).data
                }
            )

            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            
            res = {
                    'message': str(e),
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json': {}
                }
            
            return Response(res, status=status.HTTP_400_BAD_REQUEST)
        
class TransparencyColaborativeView(ListAPIView):

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = ListTransparencyColaborative
    pagination_class = StandardResultsSetPagination

    def __init__(self, **kwargs):
        self.sevice = TransparencyColaborativeService(TransparencyColaborativeImpl())

    def get_queryset(self):
        """Get queryset."""
        return self.sevice.getTransparencyColaborativeUser(self.request.user.id)
    
    def get(self, request, *args, **kwargs):

        try:
            queryset = self.get_queryset()           
            
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)
        except Exception as e:
            
            error = MessageTransactional(
                    data={
                        'message': e.__str__(),
                        'status': 400,
                        'json': {} 
                    }
                )
            error.is_valid()
            if error.errors:
                return Response(error.errors)
            return Response(error.data, status=400)
        
class TransparencyColaborativeDelete(APIView):
    serializer_class = TransparencyColaboratyCreate

    def __init__(self, **kwargs):
        self.sevice = TransparencyColaborativeService(TransparencyColaborativeImpl())

    def delete(self, request, pk, *args, **kwargs):
        try:
            
            self.sevice.deleteTransparencyColaborative(pk, request.user.id)
            return Response(status=status.HTTP_204_NO_CONTENT)
            
        except Exception as e:
            
            res = {
                    'message': str(e),
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json': {}
                }
            
            
            return Response(res, status=status.HTTP_400_BAD_REQUEST)