from typing import Any
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from entity_app.utils.permissions import HasPermission
from entity_app.utils.pagination import StandardResultsSetPagination
from entity_app.adapters.serializers import SolicitySerializer, SolicityCreateSerializer, MessageTransactional, CreateExtensionSerializer, SolicityCreateResponseSerializer
from entity_app.domain.services.solicity_service import SolicityService
from entity_app.adapters.impl.solicity_impl import SolicityImpl

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

class SolicityView(ListAPIView):
    """Solicity view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicity'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def get_queryset(self):
        """Get queryset."""
    
    def get(self, request, *args, **kwargs):
        """
        Get a list of users.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """

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
    serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicity_response'

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

