from entity_app.adapters.impl.transparency_focus_impl import TransparencyFocalImpl
from entity_app.domain.services.transparency_focus_service import TransparencyFocusService

from datetime import datetime, timedelta

from entity_app.utils.permissions import HasPermission
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.pagination import StandardResultsSetPagination

from rest_framework.generics import ListAPIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from entity_app.adapters.serializers import TransparencyFocusCreate, MessageTransactional, ListTransparencyFocus, \
    TransparencyFocusSerializer

from drf_yasg.utils import swagger_auto_schema


class CreateTransparencyFocalizada(APIView):

    serializer_class = TransparencyFocusCreate
    permission_classes = [IsAuthenticated, HasPermission]
    output_serializer_class = TransparencyFocusSerializer
    permission_required = 'add_transparencyfocal'

    def __init__(self, **kwargs):
        self.service = TransparencyFocusService(TransparencyFocalImpl())

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

        month = datetime.now().month
        year = datetime.now().year
        today = datetime.now()
        maxDatePublish = datetime.now() + timedelta(days=15)

        try:
            transparency_focus = self.service.createTransparencyFocus(
                data.validated_data['establishment_id'], data.validated_data['numeral_id'], data.validated_data['files'], month, year, today, maxDatePublish)

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
