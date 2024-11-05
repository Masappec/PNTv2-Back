from entity_app.adapters.impl.transparency_focus_impl import TransparencyFocalImpl
from entity_app.domain.services.transparency_focus_service import TransparencyFocusService

from datetime import datetime, timedelta

from entity_app.utils.permissions import HasPermission
from entity_app.domain.models.activity import ActivityLog
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.pagination import StandardResultsSetPagination

from rest_framework.generics import ListAPIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from entity_app.adapters.serializers import TransparencyFocusCreate, MessageTransactional, ListTransparencyFocus, \
    TransparencyFocusSerializer
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from drf_yasg.utils import swagger_auto_schema


class CreateTransparencyFocalizada(APIView):

    serializer_class = TransparencyFocusCreate
    permission_classes = [IsAuthenticated, HasPermission]
    output_serializer_class = ListTransparencyFocus
    permission_required = 'add_transparencyfocal'

    def __init__(self, **kwargs):
        self.service = TransparencyFocusService(TransparencyFocalImpl())
        self.numeral_service = NumeralService(NumeralImpl())

    @swagger_auto_schema(
        operation_description="Create a new publication",
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

        month = datetime.now().month-1
        year = datetime.now().year
        today = datetime.now()
        if month == 0:
            month = 12
            year = year - 1
        maxDatePublish = datetime.now() + timedelta(days=15)

        try:
            numeral_id = self.numeral_service.get_all().filter(
                type_transparency='F').first()

            if not numeral_id:
                res = MessageTransactional(
                    data={
                        'message': 'No se encontro el numeral',
                        'status': 400,
                        'json': {}
                    }
                )
                ActivityLog.objects.create(
                    user_id=request.user.id,
                    activity='Publicación de transparencia Focalizada',
                    description='Ha Creado una publicación de transparencia Focalizada',
                    ip_address=request.META.get('REMOTE_ADDR'),
                    user_agent=request.META.get('HTTP_USER_AGENT')
                )
                res.is_valid(raise_exception=True)
                return Response(res.data, status=400)

            transparency_focus = self.service.createTransparencyFocus(
                data.validated_data['establishment_id'],
                numeral_id.id,
                data.validated_data['files'], month, year, today, maxDatePublish)

            res = MessageTransactional(
                data={
                    'message': 'Publicacion creada correctamente',
                    'status': 201,
                    'json': self.output_serializer_class(transparency_focus).data
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


class TransparencyFocusView(ListAPIView):

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = ListTransparencyFocus
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_transparencyfocal'

    def __init__(self, **kwargs):
        self.service = TransparencyFocusService(TransparencyFocalImpl())

    def get_queryset(self):
        """Get queryset."""
        return self.service.getTransparencyColaborativeUser(self.request.user.id)

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


class TransparencyFocusDelete(APIView):
    serializer_class = TransparencyFocusCreate
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'delete_transparencyfocal'

    def __init__(self, **kwargs):
        self.sevice = TransparencyFocusService(TransparencyFocalImpl())

    def delete(self, request, pk, *args, **kwargs):
        try:

            self.sevice.deleteTransparencyColaborativeUser(pk, request.user.id)
            return Response(status=status.HTTP_204_NO_CONTENT)

        except Exception as e:

            res = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }

            return Response(res, status=status.HTTP_400_BAD_REQUEST)


class TransparencyFocusUpdate(APIView):

    serializer_class = TransparencyFocusCreate
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'change_transparencyfocal'

    def __init__(self, **kwargs):
        self.service = TransparencyFocusService(TransparencyFocalImpl())

    @swagger_auto_schema(
        operation_description="Update a publication",
        response={
            200: TransparencyFocusSerializer,
            400: MessageTransactional
        },
        request_body=serializer_class,
        # form data

    )
    def put(self, request, pk):

        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)

        try:

            response = self.service.update_transparency_focus(
                pk, request.user.id, data.validated_data['files'])

            res = MessageTransactional(
                data={
                    'message': 'Publicacion actualizada correctamente',
                    'status': 200,
                    'json': TransparencyFocusSerializer(response).data
                }
            )
            ActivityLog.objects.create(
                user_id=request.user.id,
                activity='Publicación de transparencia Focalizada',
                description='Ha Actualizado una publicación de transparencia Focalizada',
                ip_address=request.META.get('REMOTE_ADDR'),
                user_agent=request.META.get('HTTP_USER_AGENT')
            )

            res.is_valid(raise_exception=True)
            return Response(res.data, status=200)

        except Exception as e:

            res = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }

            return Response(res, status=status.HTTP_400_BAD_REQUEST)


class TransparecyFocusPublicView(APIView):

    permission_classes = []
    serializer_class = ListTransparencyFocus

    def __init__(self, **kwargs):
        self.service = TransparencyFocusService(TransparencyFocalImpl())

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
        try:
            year = request.query_params.get('year', None)
            month = request.query_params.get('month', None)
            establishment_id = request.query_params.get(
                'establishment_id', None)
            sorts = request.query_params.get('sort[]', None)
            if establishment_id is None:
                raise ValueError('Debe seleccionar un establecimiento')

            if year is None:
                year = datetime.now().year

            if month is None:
                month = datetime.now().month

            queryset = None
            if establishment_id == "0":
                queryset = self.service.get_all_year_month(year, month)
            else:
                queryset = self.service.get_by_year_month(
                    year, month, establishment_id)

            if sorts is not None:
                queryset = queryset.order_by(sorts)

            serializer = self.serializer_class(queryset, many=True)
            return Response(serializer.data)

        except Exception as e:
            return Response({
                'message': str(e),
                'status': 400,
                'json': {}
            }, status=400)
