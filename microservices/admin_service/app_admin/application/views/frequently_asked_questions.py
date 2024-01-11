from rest_framework.views import APIView

from app_admin.adapters.impl.frequently_asked_questions_impl import FrequentlyAskedQuestionsImpl
from app_admin.adapters.serializer import FrequentlyAskeeQuestionsSerializer, MessageTransactional, \
    FrequentlyAskedQuestionsSerializerBody
from app_admin.domain.models import FrequentlyAskedQuestions
from app_admin.domain.service.frequently_asked_questions_service import FrequentlyAskedQuestionsService
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

class FrequentlyAskedQuestionsView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = FrequentlyAskeeQuestionsSerializer
    output_serializer_class = FrequentlyAskedQuestionsSerializerBody


    def __init__(self):
        self.frequently_asked_questions_service = FrequentlyAskedQuestionsService(FrequentlyAskedQuestionsImpl())

    @swagger_auto_schema(
        operation_description="Create a Frequently Asked",
        responses={400: MessageTransactional},
        request_body= output_serializer_class

    )
    def post(self, request):
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        try:
            frequently_asked_questions = self.frequently_asked_questions_service.register_faq(data.data)
            data_response = self.output_serializer_class(data=frequently_asked_questions)
            data_response.is_valid(raise_exception=True)
            res = MessageTransactional(
                data={
                    'message': 'Datos creados correctamente',
                    'status': 201,
                    'json': data_response.data
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            print("Error:", str(e))

            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)

            return Response(res.data, status=400)


