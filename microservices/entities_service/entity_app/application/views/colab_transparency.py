from entity_app.adapters.impl.transparency_colaborative_impl import TransparencyColaborativeImpl
from entity_app.domain.services.transparency_colaborative_service import TransparencyColaborativeService

from datetime import datetime, timedelta

from entity_app.utils.permissions import HasPermission
from entity_app.domain.models.activity import ActivityLog
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.pagination import StandardResultsSetPagination

from rest_framework.generics import ListAPIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from entity_app.adapters.serializers import TransparencyColaboratyCreate, MessageTransactional, ListTransparencyColaborative
from drf_yasg.utils import swagger_auto_schema


from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl


class CreateTransparencyColaboraty(APIView):

    serializer_class = TransparencyColaboratyCreate
    permission_classes = [IsAuthenticated, HasPermission]
    output_serializer_class = ListTransparencyColaborative
    permission_required = 'add_transparencycolab'

    def __init__(self, **kwargs):
        self.service = TransparencyColaborativeService(
            TransparencyColaborativeImpl())
        self.numeral_service = NumeralService(NumeralImpl())

    @swagger_auto_schema(
        request_body=TransparencyColaboratyCreate,
        responses={201: MessageTransactional}
    )
    def post(self, request, *args, **kwargs):

        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)

        month = datetime.now().month
        year = datetime.now().year
        today = datetime.now()
        maxDatePublish = datetime.now() + timedelta(days=15)

        try:
            numeral_id = self.numeral_service.get_all().filter(
                type_transparency='C').first()
            transparency_colaborative = self.service.createTransparencyColaborative(
                data.validated_data['establishment_id'], numeral_id.id, data.validated_data['files'], month, year, today, maxDatePublish)

            res = MessageTransactional(
                data={
                    'message': 'Publicacion creada correctamente',
                    'status': 201,
                    'json': self.output_serializer_class(transparency_colaborative).data
                }
            )
            ActivityLog.objects.create(
                user_id=request.user.id,
                activity='Publicación de transparencia colaborativa',
                description='Ha creado una publicación de transparencia colaborativa',
                ip_address=request.META.get('REMOTE_ADDR'),
                user_agent=request.META.get('HTTP_USER_AGENT')
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
    permission_required = 'view_transparencycolab'

    def __init__(self, **kwargs):
        self.sevice = TransparencyColaborativeService(
            TransparencyColaborativeImpl())

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
        self.sevice = TransparencyColaborativeService(
            TransparencyColaborativeImpl())

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


class TransparencyCollabUpdate(APIView):
    serializer_class = TransparencyColaboratyCreate

    def __init__(self, **kwargs):
        self.sevice = TransparencyColaborativeService(
            TransparencyColaborativeImpl())

    def put(self, request, pk, *args, **kwargs):
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)

        try:

            response = self.sevice.update_transparency_colaborative(
                pk, request.user.id, data.validated_data['files'])
            res = MessageTransactional(
                data={
                    'message': 'Publicacion actualizada correctamente',
                    'status': 200,
                    'json': ListTransparencyColaborative(response).data
                }
            )
            ActivityLog.objects.create(
                user_id=request.user.id,
                activity='Publicación de transparencia colaborativa',
                description='Ha Actualizado una publicación de transparencia colaborativa',
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


class TransparecyCollabPublicView(APIView):

    permission_classes = []
    serializer_class = ListTransparencyColaborative

    def __init__(self, **kwargs):
        self.service = TransparencyColaborativeService(
            TransparencyColaborativeImpl())

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
            if sorts:
                queryset = queryset.order_by(sorts)
            serializer = self.serializer_class(queryset, many=True)
            return Response(serializer.data)

        except Exception as e:
            return Response({
                'message': str(e),
                'status': 400,
                'json': {}
            }, status=400)
