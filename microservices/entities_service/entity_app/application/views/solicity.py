from datetime import datetime, timedelta
from typing import Any
from rest_framework.views import APIView

from entity_app.adapters.serializers import CreateExtensionSerializer, SolicityResponseSerializer
from entity_app.adapters.impl.solicity_impl import SolicityImpl
from rest_framework.response import Response
from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q

from entity_app.utils.permissions import BelongsToEstablishment, HasPermission, IsOwnerResponseSolicity
from entity_app.utils.pagination import StandardResultsSetPagination
from entity_app.adapters.serializers import SolicitySerializer, SolicityCreateDraftSerializer, SolicityCreateWithDraftSerializer, MessageTransactional, CreateExtensionSerializer, SolicityCreateResponseSerializer
from entity_app.domain.services.solicity_service import SolicityService
from entity_app.adapters.impl.solicity_impl import SolicityImpl
from drf_yasg.utils import swagger_auto_schema
from entity_app.utils.functions import get_timedelta_for_expired


class CreateExtensionSolicityView(APIView):

    serializer_class = CreateExtensionSerializer
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'add_extension'

    def __init__(self, **kwargs: Any):
        self.service = SolicityService(solicity_repository=SolicityImpl())

    def post(self, request):
        try:
            serializer = self.serializer_class(data=request.data)
            serializer.is_valid(raise_exception=True)
            user_id = request.user.id
            response = self.service.create_extencion_solicity(
                serializer.validated_data['motive'],
                serializer.validated_data['solicity_id'],
                user_id
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

    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'add_manual_solicity'

    def __init__(self):
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

    permission_classes = [IsAuthenticated,
                          HasPermission, IsOwnerResponseSolicity]
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
    permission_classes = [IsAuthenticated,
                          HasPermission, IsOwnerResponseSolicity]
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
                files=serializer.validated_data['files'],
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


class SolicityDetailView(APIView):
    """Solicity view."""

    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'view_solicity'
    serializer_class = SolicitySerializer
    output_serializer_class = SolicitySerializer

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def get(self, request, solicity_id):
        """Get solicity."""
        try:
            solicity = self.service.get_solicity_by_id_and_user(
                solicity_id, request.user.id)

            return Response({
                'message': 'Publicacion creada correctamente',
                'status': 201,
                'json': self.output_serializer_class(solicity).data
            }, status=201)
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


class SolicityDetailEstablishmentView(APIView):
    """Solicity view."""

    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'view_solicityresponse'
    serializer_class = SolicitySerializer
    output_serializer_class = SolicitySerializer

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def get(self, request, solicity_id):
        """Get solicity."""
        try:
            solicity = self.service.get_solicity_by_id(
                solicity_id)

            return Response({
                'message': 'Publicacion creada correctamente',
                'status': 201,
                'json': self.output_serializer_class(solicity).data
            }, status=201)
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


class UpdateSolicityView(APIView):
    """Solicity view."""

    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'change_solicity'
    serializer_class = SolicityCreateWithDraftSerializer
    output_serializer_class = SolicitySerializer

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def put(self, request):
        """Update solicity."""
        try:
            serializer = self.serializer_class(data=request.data)
            serializer.is_valid(raise_exception=True)

            solicity = self.service.update_solicity(
                **serializer.validated_data,
                expiry_date=datetime.now() + get_timedelta_for_expired(),
                user_id=request.user.id
            )

            return Response({
                'message': 'Publicacion creada correctamente',
                'status': 201,
                'json': self.output_serializer_class(solicity).data
            }, status=201)
        except Exception as e:
            print("Error:", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': '{}'
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)


class SolicityView(ListAPIView):
    """Solicity view."""

    permission_classes = [IsAuthenticated, HasPermission]
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_solicity'
    serializer_class = SolicitySerializer

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def get_queryset(self, user_id):
        """Get queryset."""
        data = self.service.get_user_solicities(user_id)
        return data

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

        try:

            queryset = self.get_queryset(request.user.id)

            search = request.query_params.get('search', None)
            if search is not None:
                queryset = queryset.filter(
                    Q(number_saip__icontains=search) | Q(establishment__name__icontains=search))

            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)
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


class SolicityCreateDraftView(APIView):
    """Solicity Response view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicityCreateDraftSerializer
    output_serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'add_solicity'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    @swagger_auto_schema(
        operation_description="create a draft of solicity",
        response={201: output_serializer_class, 400: MessageTransactional},
        request_body=serializer_class,
        # form data
    )
    def post(self, request, *args, **kwargs):
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        solicity = None

        try:
            data_validated = data.validated_data
            data_validated['user_id'] = request.user.id
            data_validated['expiry_date'] = datetime.now() + \
                get_timedelta_for_expired()
            solicity = self.service.create_solicity_draft(
                **data_validated
            )

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


class SolicityWithoutDraftView(APIView):
    """Solicity Response view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicityCreateDraftSerializer
    output_serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'add_solicity'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    @swagger_auto_schema(
        operation_description="create a solicity without draft",
        response={201: output_serializer_class, 400: MessageTransactional},
        request_body=serializer_class,
        # form data
    )
    def post(self, request, *args, **kwargs):
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        solicity = None

        try:
            solicity = self.service.send_solicity_without_draft(
                **data.validated_data,
                expiry_date=datetime.now() + get_timedelta_for_expired(),
                user_id=request.user.id
            )

            solicityser = self.output_serializer_class(solicity)

            return Response(data={
                'message': 'Publicacion creada correctamente',
                'status': 201,
                'json': solicityser.data
            }, status=201)
        except Exception as e:
            print("Error: ", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': '{}'
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)


class SolicityGetLastDraftView(APIView):
    """Solicity Response view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicityCreateDraftSerializer
    output_serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'add_solicity'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    @swagger_auto_schema(
        operation_description="get the last draft of solicity",
        response={201: output_serializer_class, 400: MessageTransactional},
        # form data
    )
    def get(self, request, *args, **kwargs):

        try:
            solicity = self.service.get_solicity_last_draft(request.user.id)
            print("Solicity:  ", solicity)
            if solicity is None:
                res = MessageTransactional(
                    data={
                        'message': 'No se encontro un borrador',
                        'status': 200,
                        'json': {}
                    }
                )
                res.is_valid(raise_exception=True)
                return Response(res.data, status=400)
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
            print("Error: ", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)


class SolicitySendView(APIView):
    """Solicity Response view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = SolicityCreateWithDraftSerializer
    output_serializer_class = SolicitySerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'add_solicity'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    @swagger_auto_schema(
        operation_description="send a solicity from draft",
        response={201: output_serializer_class, 400: MessageTransactional},
        request_body=serializer_class,
        # form data
    )
    def post(self, request, *args, **kwargs):
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        solicity = None

        try:
            date = datetime.now() + get_timedelta_for_expired()
            solicity = self.service.send_solicity_from_draft(
                **data.validated_data,
                expiry_date=date,
                user_id=request.user.id
            )

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
    permission_required = 'view_solicityresponse'
    output_serializer_class = SolicityResponseSerializer

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    def get_queryset(self, use_id):
        """Get queryset."""
        return self.service.get_entity_user_solicities(use_id).order_by('-created_at')

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
        data = request.data

        try:

            queryset = self.get_queryset(
                request.user.id
            )

            # ['number_saip', 'first_name', 'last_name', 'status', 'expiry_date', 'motive']
            order_by = request.query_params.get('sort[]', None)
            if order_by is not None:
                queryset = queryset.order_by(order_by)

            search = request.query_params.get('search', None)
            if search is not None:
                queryset = queryset.filter(
                    Q(number_saip__icontains=search) | Q(first_name__icontains=search) | Q(last_name__icontains=search))

            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            return Response(serializer.data)
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

    permission_classes = [IsAuthenticated,
                          HasPermission]
    serializer_class = SolicityCreateResponseSerializer
    pagination_class = StandardResultsSetPagination
    output_serializer_class = SolicitySerializer
    permission_required = 'add_solicityresponse,add_solicity'

    def __init__(self):
        self.service = SolicityService(SolicityImpl())

    @swagger_auto_schema(
        operation_description="create a response of solicity",
        response={
            201: output_serializer_class,
            400: MessageTransactional
        },
        request_body=serializer_class,
        # form data

    )
    def post(self, request, *args, **kwargs):
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        solicity_response = None

        try:

            solicity_response = self.service.create_solicity_response(
                data.validated_data['id_solicitud'],
                request.user.id, data.validated_data['text'], data.validated_data['files'],
                data.validated_data['attachment'])
            data_ser = self.output_serializer_class(solicity_response)

            return Response({
                'message': 'Solicity respondida correctamente',
                'status': 200,
                'json': data_ser.data
            }, status=201)

        except Exception as e:
            print("Error:", e)

            return Response({
                'message': str(e),
                'status': 400,
                'json': {}
            }, status=400)
