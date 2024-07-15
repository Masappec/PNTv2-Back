from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from app_admin.domain.service.smtp_service import SmtpService
from app_admin.adapters.impl.smtp_impl import StmpImpl
from app_admin.adapters.serializer import ConfigurationResponseSerializer, MessageTransactional, ConfigurationSerializer
from app_admin.utils.permission import HasPermission


class SMTPGET(APIView):

    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'view_configuration'

    def __init__(self):
        self.smtp_service = SmtpService(StmpImpl())

    def get(self, request):
        try:
            config = self.smtp_service.get_config_list_obj()
            serializer = ConfigurationResponseSerializer(config, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            print(e )
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 200,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=status.HTTP_200_OK)


class SMTPUPDATE(APIView):
    
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'change_configuration'
    serializer_class = ConfigurationSerializer
    output_serializer_class = ConfigurationResponseSerializer
    

    def __init__(self):
        self.smtp_service = SmtpService(StmpImpl())

    def put(self, request):
        try:
            data_request = self.serializer_class(data=request.data, many=True)
            data_request.is_valid(raise_exception=True)
            config_dict = {}
            for item in data_request.validated_data:
                config_dict[item['name']] = item['value']
            print(config_dict)
            config = self.smtp_service.setup(config_dict)
            serializer = ConfigurationResponseSerializer(config, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 200,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=status.HTTP_200_OK)