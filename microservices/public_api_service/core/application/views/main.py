from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import serializers
from core.models import Metadata, CSVData
from drf_yasg.utils import swagger_auto_schema
from rest_framework_mongoengine.serializers import DocumentSerializer, EmbeddedDocumentSerializer
from django.http import StreamingHttpResponse
import json


def slugify(value):
    string = value.lower().replace(" ", "-")
    #replazar tilde
    string = string.replace("á", "a")
    string = string.replace("é", "e")
    string = string.replace("í", "i")
    string = string.replace("ó", "o")
    string = string.replace("ú","u")
    string = string.strip()
    return string

class PersonalRemuneraciones(APIView):
    
    
    class InputSerializerPr(serializers.Serializer):
        names = serializers.CharField()
        institution = serializers.CharField()
        
    class OutputSerializerPr(serializers.Serializer):
        names = serializers.CharField()
        institutional_job = serializers.CharField()
        unit = serializers.CharField()
        regime = serializers.CharField()
        name = serializers.CharField()

    
    @swagger_auto_schema(
        request_body=InputSerializerPr,
        responses={200: OutputSerializerPr}
    )
    def post(self, request):
        serializer = self.InputSerializerPr(data=request.data)
        serializer.is_valid(raise_exception=True) 
        names = serializer.validated_data['names']
        institution = serializer.validated_data['institution']
        
        
        numerals_list = [
            "Numeral 2.1",
            "Numeral 2.2",
            "Numeral 3"
        ]
        
        
        try:
            res = CSVData.objects(
                metadata__numeral__in=numerals_list,
                metadata__establishment_identification=institution
            )

            if not res:
                return Response({'detail': 'No documents found.'}, status=404)

            result = self.process_results(res)
            return Response(result, status=200)

        except Exception as e:
            return Response({'detail': str(e)}, status=500)
        
    def process_results(self, documents):
        numeral_21_data = []
        additional_data = {}

        numeral_columns_map = {
            "Numeral 2.1": {
                "nombre_campo": "Apellidos y Nombres de los servidores y servidoras",
                "puesto_campo": "Puesto Institucional",
                "unidad_campo": "Unidad a la que pertenece"
            },
            "Numeral 2.2": {
                "nombre_campo": "Apellidos y Nombres de los servidores y servidoras",
                "puesto_campo": "Puesto Institucional",
                "unidad_campo": "Unidad a la que pertenece"
            },
            "Numeral 3": {
                "puesto_campo": "Puesto Institucional ",
                "remuneracion_campo": "Remuneración mensual unificada",
                "grado_campo": "Grado jerárquico o escala al que pertenece el puesto" 
            }
        }

        for doc in documents:
            numeral = doc.metadata.numeral
            columns = doc.metadata.columns
            data = doc.data

            for row in data:
                row_dict = dict(zip(columns, row))
                
                

                if numeral == "Numeral 2.1":
                    nombre = row_dict.get(
                        numeral_columns_map[numeral]["nombre_campo"], "").strip()
                    puesto = row_dict.get(
                        numeral_columns_map[numeral]["puesto_campo"], "").strip()
                    unidad = row_dict.get(
                        numeral_columns_map[numeral]["unidad_campo"], "").strip()

                    numeral_21_data.append({
                        "puesto": puesto,
                        "unidad": unidad,
                        "remuneracion": "",
                        "grado": "",
                        "remuneracion": "",
                        "nombre": nombre,
                    })

                elif numeral == "Numeral 2.2":
                    nombre = row_dict.get(
                        numeral_columns_map[numeral]["nombre_campo"], "").strip()
                    puesto = row_dict.get(
                        numeral_columns_map[numeral]["puesto_campo"], "").strip()
                    unidad = row_dict.get(
                        numeral_columns_map[numeral]["unidad_campo"], "").strip()

                    if nombre not in additional_data:
                        additional_data[nombre] = {}

                    additional_data[nombre]["puesto"] = puesto
                    additional_data[nombre]["unidad"] = unidad

                elif numeral == "Numeral 3":
                    puesto = row_dict.get(
                        numeral_columns_map[numeral]["puesto_campo"], "").strip()
                    remuneracion = row_dict.get(
                        numeral_columns_map[numeral]["remuneracion_campo"], "").strip()
                    grado = row_dict.get(
                        numeral_columns_map[numeral]["grado_campo"], "").strip()
                    if puesto not in additional_data:
                        additional_data[puesto] = {}

                    additional_data[puesto]["remuneracion"] = remuneracion
                    additional_data[puesto]["grado"] = grado
        # Enriquecer los datos de Numeral 2.1 con los adicionales
        for item in numeral_21_data:
            nombre = item["nombre"]
            puesto = item["puesto"]

            if nombre in additional_data:
                item.update(additional_data[nombre])
            elif puesto in additional_data:
                item.update(additional_data[puesto])

        return numeral_21_data


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






