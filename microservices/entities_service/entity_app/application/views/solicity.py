from typing import Any
from rest_framework.views import APIView

from entity_app.adapters.serializers import CreateExtensionSerializer, SolicityResponseSerializer
from entity_app.adapters.impl.solicity_impl import SolicityImpl
from entity_app.domain.services.solicity import SolicityService
from rest_framework.response import Response
from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q

from entity_app.utils.permissions import HasPermission, IsOwnerResponseSolicity
from entity_app.utils.pagination import StandardResultsSetPagination
from entity_app.adapters.serializers import SolicitySerializer, SolicityCreateSerializer, MessageTransactional, CreateExtensionSerializer, SolicityCreateResponseSerializer
from entity_app.domain.services.solicity_service import SolicityService
from entity_app.adapters.impl.solicity_impl import SolicityImpl

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

class SolicityView(ListAPIView):
    """Solicity view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicity'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def get_queryset(self, user_id):
        """Get queryset."""
        return self.service.get_user_solicities(user_id)
    
    def get(self, request, *args, **kwargs):
        """
        Get a list of solicities.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        data=self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        queryset = None

        try:
            relations = self.service.validate_user_establishmentt(data.establishment_id, request.user.id)

            if relations is True:
                queryset = self.get_queryset(request.user.id)

                search = request.query_params.get('search', None)
                if search is not None:
                    queryset = queryset.filter(
                        Q(name__icontains=search) | Q(description__icontains=search))
                
                page = self.paginate_queryset(queryset)
                if page is not None:
                    serializer = self.get_serializer(page, many=True)
                    return self.get_paginated_response(serializer.data)
                
                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 200,
                        'json': self.output_serializer_class(queryset).data
                    }
                )
            else:
                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 200,
                        'json': {}
                    }
                )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
                print("Error:", e)
                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 400,
                        'json': {}
                    }
                )
                res.is_valid(raise_exception=True)
                return Response(res.data, status=400) 

class SolicityCreateView(APIView):
    """Solicity Response view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicityCreateSerializer
    output_serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'add_solicity'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def post(self, request, *args, **kwargs):
        data=self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        solicity = None

        try:
            solicity = self.solicity_service.create_citizen_solicity()

            res = MessageTransactional(
                data={ 
                    'message': 'Publicacion creada correctamente',
                    'status': 201,
                    'json': self.output_serializer_class(solicity).data
                }
            )

            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            print("Error:", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)

class SolicityResponseView(ListAPIView):
    """Solicity Response view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicityCreateResponseSerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicity_response'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def get_queryset(self, entity_id):
        """Get queryset."""
        return self.service.get_entity_solicities(entity_id)
    
    def get(self, request, *args, **kwargs):
        """
        Get a list of solicities.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        data=self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        queryset = None

        try:
            relations = self.service.validate_user_establishmentt(data.establishment_id, request.user.id)

            if relations is True:
                queryset = self.get_queryset(data.establishment_id)

                search = request.query_params.get('search', None)
                if search is not None:
                    queryset = queryset.filter(
                        Q(name__icontains=search) | Q(description__icontains=search))
                
                page = self.paginate_queryset(queryset)
                if page is not None:
                    serializer = self.get_serializer(page, many=True)
                    return self.get_paginated_response(serializer.data)
                
                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 200,
                        'json': self.output_serializer_class(queryset).data
                    }
                )
            else:
                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 200,
                        'json': {}
                    }
                )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
                print("Error:", e)
                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 400,
                        'json': {}
                    }
                )
                res.is_valid(raise_exception=True)
                return Response(res.data, status=400) 

class SolicityCreateResponseView(APIView):
    """ Solicity Create Response """

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicityCreateResponseSerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'add_solicity_response'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def post(self, request, *args, **kwargs):
        data=self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        solicity_response = None

        try:
            relations = self.service.validate_user_establishmentt(data.establishment_id, request.user.id)

            if relations is True:
                solicity_response = self.service.create_solicity_response(data.id_solicitud, request.user.id, data.text, data.category_id, data.files, data.attachment)

                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 200,
                        'json': self.output_serializer_class(solicity_response).data
                    }
                )
            else:
                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 200,
                        'json': {}
                    }
                )

            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)

        except Exception as e:
                print("Error:", e)
                res = MessageTransactional(
                    data={
                        'message': str(e),
                        'status': 400,
                        'json': {}
                    }
                )
                res.is_valid(raise_exception=True)
                return Response(res.data, status=400) 

