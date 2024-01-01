from rest_framework.views import APIView
from app_admin.adapters.impl.form_field_impl import FormFieldsImpl
from rest_framework.response import Response
from rest_framework import status
from app_admin.domain.service.form_field_service import FormFieldsService
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from app_admin.adapters.serializer import FormFieldsListSerializer

class FormField(APIView):
    
    permission_classes = []
    serializer_class = None
    
    def __init__(self):
        self.form_field_service = FormFieldsService(FormFieldsImpl())
        
    @swagger_auto_schema(
        operation_description="Create a establishment",
        response={
            400: None,
        },
        manual_parameters=[
            openapi.Parameter(
                name='role',
                in_=openapi.IN_QUERY,
                type=openapi.TYPE_STRING,
                required=True,
                description='Rol de usuario'
            ),
            openapi.Parameter(
                name='form_type',
                in_=openapi.IN_QUERY,
                type=openapi.TYPE_STRING,
                required=True,
                description='tipo de formulario'
            ),
        ],
        #form data
        
    )
    def get(self, request):
        #queryparams = request.query_params
        role = request.query_params.get('role')
        form_type = request.query_params.get('form_type')
        if role is None or form_type is None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        
        form_fields = self.form_field_service.get_form_fields_by_role_and_form_type(role, form_type)
        res = FormFieldsListSerializer(form_fields, many=True)
        
        return Response(res.data, status=status.HTTP_200_OK)