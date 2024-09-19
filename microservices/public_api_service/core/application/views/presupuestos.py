from rest_framework.views import APIView
from rest_framework.response import Response
from datetime import datetime
from core.models import TransparencyActive, FilePublication
from rest_framework import serializers
from drf_yasg.utils import swagger_auto_schema


class FilePublicationSerializer(serializers.ModelSerializer):

    class Meta:
        model = FilePublication
        fields = (
            'id',
            'name',
            'description',
            'url_download',
        )

class PresupuestoView(APIView):
    
    
    class InputSerializerPresupuesto(serializers.Serializer):
        ruc = serializers.CharField(allow_blank=True, allow_null=True)
        year = serializers.IntegerField()
        month = serializers.IntegerField()
    class OutputSerializerPresupuesto(serializers.ModelSerializer):
        files = FilePublicationSerializer(many=True)
        establishment_name = serializers.SerializerMethodField(
            method_name='get_establishment_name')
        class Meta:
            model = TransparencyActive
            fields = '__all__'
            
        def get_establishment_name(self, obj):
            return obj.establishment.name
            
            
    @swagger_auto_schema(
        request_body=InputSerializerPresupuesto,
        responses={200: OutputSerializerPresupuesto}
    )
    def post(self, request, *args, **kwargs):
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
            serializer = self.InputSerializerPresupuesto(data=request.data)
            serializer.is_valid(raise_exception=True)

            year = serializer.validated_data['year']
            month = serializer.validated_data['month']
            ruc = serializer.validated_data['ruc']

            if year is None:
                year = datetime.now().year

            if month is None:
                month = datetime.now().month

            queryset = None
            if ruc is None:
                queryset = TransparencyActive.objects.filter(
                    year=year,
                    month=month,
                    numeral__name='Numeral 6'
                )
            else:
                queryset = TransparencyActive.objects.filter(
                    year=year,
                    month=month,
                    establishment__identification=ruc,
                    numeral__name='Numeral 6'
                )

            serializer = self.OutputSerializerPresupuesto(queryset, many=True)
            return Response(serializer.data)

        except Exception as e:
            return Response({
                'message': str(e),
                'status': 400,
                'json': {}
            }, status=400)