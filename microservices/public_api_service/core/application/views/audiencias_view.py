from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import serializers
from core.models import Metadata, CSVData
from drf_yasg.utils import swagger_auto_schema
from rest_framework_mongoengine.serializers import DocumentSerializer, EmbeddedDocumentSerializer
from django.http import StreamingHttpResponse
import json
from hermetrics.levenshtein import Levenshtein

lev = Levenshtein()
class AudienciasView(APIView):
    
    class InputSerializerAudience(serializers.Serializer):
        names = serializers.CharField()
        year = serializers.IntegerField()
        month = serializers.IntegerField()


    @swagger_auto_schema(
        request_body=InputSerializerAudience,
    )
    def post(self, request):
        
        serializer = self.InputSerializerAudience(data=request.data)
        serializer.is_valid(raise_exception=True)
        year = serializer.validated_data['year']
        month = serializer.validated_data['month']
        name = serializer.validated_data['names']
        res = CSVData.objects(
            metadata__numeral='Numeral 17',
            metadata__year=str(year),
            metadata__month=str(month)
        )
        lista = []
        for doc in res:
            print(doc.metadata.establishment_name )
            for data in doc.data:
                print(data[0] )
                if lev.similarity(name, data[0]) > 0.3:

                    lista.append({
                        "institucion":doc.metadata.establishment_name,
                        "nombre": data[0],
                        "puesto":data[1],
                        "asunto":data[2],
                        "fecha":data[3],
                        "modalidad":data[4],
                        "lugar":data[5],
                        "descripcion":data[6],
                        "duracion":data[7],
                        "externa":data[8],
                        "institucion_ext":data[9],
                        "enlace":data[10]
                    })
            
            
        return Response(lista)
    
    
class Numeral16View(APIView):


    def get(self, request):
        ruc = request.query_params.get('ruc')
        year = request.query_params.get('year')
        if ruc is None:
            return Response("Error, ruc is required", status=400) 

        res = CSVData.objects(
            metadata__numeral='Numeral 16',
            metadata__year=str(year),
            metadata__establishment_identification=ruc
        )
        lista = []
        for doc in res:
            print(doc.metadata.establishment_name )
            for data in doc.data:

                lista.append({
                    "institucion":doc.metadata.establishment_name,
                    "tema": data[0],
                    "numero_resolucion":data[1],
                    "fecha_clasificacion":data[2],
                    "periodo_vigencia":data[3],
                    "enlace":data[4]
                })
            
            
        return Response(lista)
            
        
        
        
