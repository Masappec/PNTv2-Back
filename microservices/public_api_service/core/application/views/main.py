from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import serializers
from core.models import Metadata, CSVData
from drf_yasg.utils import swagger_auto_schema
from rest_framework_mongoengine.serializers import DocumentSerializer, EmbeddedDocumentSerializer
from django.http import StreamingHttpResponse
import json
from hermetrics.levenshtein import Levenshtein





class MainView(APIView):
    
    

    class InputSerializer(serializers.Serializer):
        numerals = serializers.ListField(child=serializers.CharField())
        article = serializers.CharField()
        year = serializers.CharField()
        month = serializers.CharField()
        establishment = serializers.CharField()
        establishment = serializers.CharField(
            allow_null=True, allow_blank=True)

        fields = serializers.ListField(child=serializers.CharField())
    
    
    class OutputSerializer(EmbeddedDocumentSerializer):
        class Meta:
            model = CSVData
            fields = '__all__'
    @swagger_auto_schema(
        request_body=InputSerializer,
        responses={200: OutputSerializer}
    )
    def post(self, request):
        serializer = self.InputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        numerals = serializer.validated_data['numerals']
        articles = serializer.validated_data['article']
        year = serializer.validated_data['year']
        month = serializer.validated_data['month']
        ruc = serializer.validated_data['establishment']

        if not ruc:
            res = CSVData.objects(
                metadata__numeral__in=numerals,
                metadata__year=year,
                metadata__month=month,
                metadata__article=articles,
            )
        else:
            res = CSVData.objects(
                metadata__numeral__in=numerals,
                metadata__year=year,
                metadata__month=month,
                metadata__article=articles,
                metadata__establishment_identification=ruc
            )


        
        return Response(self.OutputSerializer(res, many=True).data)
        
        
class MainViewStream(APIView):

    class InputSerializerStream(serializers.Serializer):
        numerals = serializers.ListField(child=serializers.CharField())
        article = serializers.CharField()
        year = serializers.CharField()
        month = serializers.CharField()
        establishment = serializers.CharField(allow_null=True,allow_blank=True)
        fields = serializers.ListField(child=serializers.CharField())

    class OutputSerializerStream(EmbeddedDocumentSerializer):
        class Meta:
            model = CSVData
            fields = '__all__'

    
    def post(self, request):
        serializer = self.InputSerializerStream(data=request.data)
        serializer.is_valid(raise_exception=True)

        numerals = serializer.validated_data['numerals']
        articles = serializer.validated_data['article']
        year = serializer.validated_data['year']
        month = serializer.validated_data['month']
        ruc = serializer.validated_data['establishment']
        if ruc=='':
            res = CSVData.objects(
                metadata__numeral__in=numerals,
                metadata__year=year,
                metadata__month=month,
                metadata__article=articles,
            )
        else:
            res = CSVData.objects(
                metadata__numeral__in=numerals,
                metadata__year=year,
                metadata__month=month,
                metadata__article=articles,
                metadata__establishment_identification=ruc
            )
        print(f"Total documentos que coinciden : {len(res)}")

        for result in res:
            print(result.metadata.to_mongo())
        def stream_queryset(queryset):
            for obj in queryset:
                data = self.OutputSerializerStream(obj).data
                yield f"data: {json.dumps(data)}\n\n"

        response = StreamingHttpResponse(
            stream_queryset(res), content_type="text/event-stream")
        response['Cache-Control'] = 'no-cache'
        # Para nginx, deshabilita el buffering si es necesario
        response['X-Accel-Buffering'] = 'no'
        return response




'''
class DescargaMasiva(APIView):
    
    class InputSerializerStream(serializers.Serializer):
        mes = serializers.IntegerField()
        anio = serializers.IntegerField()
        numeral = serializers.CharField()
        institucion = serializers.CharField(allow_blank=True)
        
    
        
'''
        
