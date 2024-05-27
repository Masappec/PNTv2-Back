from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from app_admin.adapters.serializer import PedagogyAreaSerializerCreate, PedagogyAreaSerializerResponse, MessageTransactional
from app_admin.adapters.impl.pedagogy_area_impl import PedagogyAreaImpl
from app_admin.domain.service.pedagogy_area_service import PedagogyAreaService
from drf_yasg.utils import swagger_auto_schema
from rest_framework.permissions import IsAuthenticated
from app_admin.utils.permission import HasPermission


class PedagogyAreaCreateView(APIView):

    permission_classes = [IsAuthenticated, HasPermission]

    permission_required = 'app_admin.add_pedagogyarea'
    serializer_class = PedagogyAreaSerializerCreate
    output_serializer_class = PedagogyAreaSerializerResponse

    def __init__(self):

        self.service = PedagogyAreaService(
            respository=PedagogyAreaImpl()
        )

    @swagger_auto_schema(
        tags=['Pedagogy Area'],
        operation_summary='Create Pedagogy Area',
        operation_description='Create Pedagogy Area',
        request_body=PedagogyAreaSerializerCreate,
        responses={
            201: PedagogyAreaSerializerResponse,
            400: MessageTransactional
        }
    )
    def post(self, request, format=None):

        serializer = self.serializer_class(data=request.data)

        try:
            serializer.is_valid(raise_exception=True)

            faq = serializer.validated_data.get('faq')
            tutorial = serializer.validated_data.get('tutorial')
            normative = serializer.validated_data.get('normative')

            user_id = request.user.id if request.user.id else 1

            pedagogy_area = self.service.create(
                faq, tutorial, normative, user_id)

            output_serializer = self.output_serializer_class(pedagogy_area)

            res = MessageTransactional(
                data={
                    'message': 'Pedagogy area created successfully',
                    'status': 201,
                    'json': output_serializer.data
                }
            )

            res.is_valid(raise_exception=True)

            return Response(res.data, status=status.HTTP_201_CREATED)

        except Exception as e:
            print(e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )

            res.is_valid(raise_exception=True)

            return Response(res.validated_data, status=status.HTTP_400_BAD_REQUEST)


class PedagogyAreaView(APIView):

    permission_classes = []

    serializer_class = PedagogyAreaSerializerResponse

    def __init__(self):
        self.service = PedagogyAreaService(
            respository=PedagogyAreaImpl()
        )

    @swagger_auto_schema(
        tags=['Pedagogy Area'],
        operation_summary='Select Pedagogy Area',
        operation_description='Select Pedagogy Area',
        responses={
            200: PedagogyAreaSerializerResponse,
            400: MessageTransactional
        }
    )
    def get(self, request, format=None):
        try:
            pedagogy_area = self.service.select_area()
            if not pedagogy_area:
                raise ValueError('Pedagogy area not found')
            serializer = self.serializer_class(pedagogy_area)

            res = MessageTransactional(
                data={
                    'message': 'Pedagogy area selected successfully',
                    'status': 200,
                    'json': serializer.data
                }
            )

            res.is_valid(raise_exception=True)

            return Response(res.data, status=status.HTTP_200_OK)

        except Exception as e:

            return Response(data={
                'message': str(e),
                'status': 400,
                'json': {}
            }, status=status.HTTP_400_BAD_REQUEST)
