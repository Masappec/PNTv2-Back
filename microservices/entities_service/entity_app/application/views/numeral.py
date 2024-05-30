from datetime import datetime
from typing import Any
from rest_framework.views import APIView
from rest_framework.generics import ListAPIView
from entity_app.adapters.serializers import NumeralResponseSerializer, NumeralDetailSerializer, TransparecyActiveCreate, TransparencyCreateResponseSerializer
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entity_app.utils.permissions import BelongsToEstablishment, NumeralIsOwner, HasPermission
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q

from entity_app.adapters.serializers import MessageTransactional
from rest_framework.response import Response
from rest_framework import status
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from entity_app.domain.models.publication import FilePublication
from entity_app.adapters.messaging.channels import CHANNEL_ESTABLISHMENT_NUMERAL
from entity_app.adapters.messaging.publish import Publisher
from entity_app.adapters.messaging.events import TRANSPARENCY_ACTIVE_UPDATE


class NumeralsByEstablishment(APIView):

    serializer_class = NumeralResponseSerializer

    permission_classes = [IsAuthenticated, BelongsToEstablishment]

    def __init__(self, **kwargs: Any) -> None:
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

    @swagger_auto_schema(
        operation_description="Get all numerals by establishment",
        responses={200: NumeralResponseSerializer},
        manual_parameters=[
            openapi.Parameter('establishtment_id', openapi.IN_QUERY,
                              type=openapi.TYPE_STRING, description="Establishtment id"),
        ]
    )
    def get(self, request):

        try:
            if not request.query_params.get('establishtment_id'):
                return Response({
                    'message': 'establishtment_id is required',
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json': {}
                }, status=status.HTTP_400_BAD_REQUEST)

            numerals = self.service.get_by_entity(
                request.query_params.get('establishtment_id'))

            serializer = self.serializer_class(numerals, many=True, context={
                                               'establishment_id': request.query_params.get('establishtment_id')})

            return Response(serializer.data)

        except Exception as e:
            return Response({
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }, status=status.HTTP_400_BAD_REQUEST)


class NumeralDetail(APIView):

    serializer_class = NumeralDetailSerializer

    permission_classes = [IsAuthenticated, NumeralIsOwner]

    def __init__(self, **kwargs: Any) -> None:
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

    @swagger_auto_schema(
        operation_description="Get numeral detail",
        responses={200: NumeralResponseSerializer},
        manual_parameters=[
            openapi.Parameter('numeral_id', openapi.IN_QUERY,
                              type=openapi.TYPE_STRING, description="Numeral id"),
            openapi.Parameter('type', openapi.IN_QUERY,
                              type=openapi.TYPE_STRING, description="Type of numeral")
        ]
    )
    def get(self, request):

        try:
            numeral = None
            if request.query_params.get('type') is not None:
                numeral = self.service.get_numeral_focalized_or_collab(
                    request.query_params.get('type'))

            else:
                if request.query_params.get('numeral_id') is None:
                    return Response({
                        'message': 'numeral_id is required',
                        'status': status.HTTP_400_BAD_REQUEST,
                        'json': {}
                    }, status=status.HTTP_400_BAD_REQUEST)

                numeral = self.service.get(
                    request.query_params.get('numeral_id'))
            if numeral is None:
                return Response({
                    'message': 'Numeral not found',
                    'status': status.HTTP_404_NOT_FOUND,
                    'json': {}
                }, status=status.HTTP_404_NOT_FOUND)
            serializer = self.serializer_class(numeral)

            return Response(serializer.data)

        except Exception as e:
            return Response({
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }, status=status.HTTP_400_BAD_REQUEST)


class ListNumeralAllow(APIView):
    """Publication view."""

    permission_classes = [IsAuthenticated]
    serializer_class = NumeralDetailSerializer

    def __init__(self):
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

    def get(self, request, *args, **kwargs):
        """
        Get a list of transparency.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:
            queryset = self.service.get_by_default(False)

            serializer = self.serializer_class(queryset, many=True)

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


class ListNumeral(ListAPIView):
    """Publication view."""

    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = NumeralResponseSerializer

    def __init__(self):
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

    def get_queryset(self):
        """Get queryset."""
        return self.service.get_all_transparency()

    def get(self, request, *args, **kwargs):
        """
        Get a list of transparency.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:
            queryset = self.get_queryset()
            search = request.query_params.get('search', None)
            date = request.query_params.get('date', None)
            numeral_id = request.query_params.get('numeral_id', None)

            if search is not None:
                queryset = queryset.filter(
                    Q(name__icontains=search) | Q(description__icontains=search))

            if date is not None:
                queryset = queryset.filter(Q(date=date))

            if numeral_id is not None:
                queryset = queryset.filter(numeral_id=numeral_id)

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


class PublishNumeral(APIView):

    permission_classes = [IsAuthenticated,
                          HasPermission, BelongsToEstablishment]
    serializer_class = TransparecyActiveCreate
    output_serializer_class = TransparencyCreateResponseSerializer

    permission_required = 'add_transparencyactive'

    def __init__(self):
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

    @swagger_auto_schema(
        operation_description="Publish numeral",
        request_body=TransparecyActiveCreate,
        responses={200: TransparencyCreateResponseSerializer}
    )
    def post(self, request, *args, **kwargs):
        """
        Create Numeral
        """

        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        month = datetime.now().month
        year = datetime.now().year
        fecha_actual = datetime.now()
        transparency = self.service.get_transparency_by_numeral(
            data.validated_data['numeral_id'], month, year,
            data.validated_data['establishment_id']
        )
        mensaje = ""

        try:
            if transparency is None:
                transparency = self.service.create_transparency(
                    data.validated_data['establishment_id'], data.validated_data['numeral_id'], data.validated_data['files'],
                    month, year, fecha_actual)
            else:
                if transparency.published is True:
                    raise Exception(
                        "Ya existe una publicacion para este numeral")

            result = self.output_serializer_class(transparency)
            res = MessageTransactional(
                data={
                    'message': 'Publicacion creada correctamente',
                    'status': 201,
                    'json': result.data
                }
            )
            res.is_valid(raise_exception=True)

            return Response(res.data, status=200)
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


class NumeralEditPublish(APIView):

    permission_classes = [IsAuthenticated,
                          HasPermission, BelongsToEstablishment]
    serializer_class = TransparecyActiveCreate
    output_serializer_class = TransparencyCreateResponseSerializer

    permission_required = 'add_transparencyactive'

    def __init__(self):
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )
        self.publisher = Publisher(CHANNEL_ESTABLISHMENT_NUMERAL)

    @swagger_auto_schema(
        operation_description="Edit Publish numeral",
        request_body=TransparecyActiveCreate,
        responses={200: TransparencyCreateResponseSerializer}
    )
    def put(self, request, *args, **kwargs):
        """
        Edit Publish Numeral
        """

        try:
            data = self.serializer_class(data=request.data)
            data.is_valid(raise_exception=True)
            month = datetime.now().month
            year = datetime.now().year
            fecha_actual = datetime.now()
            transparency = self.service.get_transparency_by_numeral(
                data.validated_data['numeral_id'], month, year,
                data.validated_data['establishment_id']
            )

            if transparency is None:
                raise Exception("No existe una publicacion para este numeral")

            transparency.files.clear()
            transparency.files.set(data.validated_data['files'])
            transparency.save()
            list_files = FilePublication.objects.filter(
                id__in=data.validated_data['files'])
            for file in list_files:
                root = 'transparencia/' + \
                    str(transparency.establishment.identification) + '/' + \
                    str(transparency.numeral.name) + '/' + \
                    str(transparency.year) + '/' + str(transparency.month)
                FilePublication.move_file(file, root)

            result = self.output_serializer_class(transparency)
            self.publisher.publish({
                'type': TRANSPARENCY_ACTIVE_UPDATE,
                'payload': {
                    'filepaths': [file.url_download.path for file in list_files.filter(description='Conjunto de datos')],
                    'date': fecha_actual.strftime('%Y-%m-%d'),
                    'month': month,
                    'year': year,
                    'user': transparency.establishment_id,
                    'establishment_identification': transparency.establishment.identification,
                    'numeral': transparency.numeral.name
                }
            })
            res = MessageTransactional(
                data={
                    'message': 'Publicacion editada correctamente',
                    'status': 201,
                    'json': result.data
                }
            )

            res.is_valid(raise_exception=True)
            return Response(res.data, status=200)

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
