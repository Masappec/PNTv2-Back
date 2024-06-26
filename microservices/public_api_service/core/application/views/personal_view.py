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


def slugify(value):
    string = value.lower().replace(" ", "-")
    # replazar tilde
    string = string.replace("á", "a")
    string = string.replace("é", "e")
    string = string.replace("í", "i")
    string = string.replace("ó", "o")
    string = string.replace("ú", "u")
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
                return Response([], status=200)

            result = self.process_results(res, names)
            return Response(result, status=200)

        except Exception as e:
            return Response({'detail': str(e)}, status=500)

    def process_results(self, documents, name):
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
                "puesto_campo": "Puesto Institucional",
                "remuneracion_campo": "Remuneración mensual unificada",
                "grado_campo": "Grado jerárquico o escala al que pertenece el puesto",
                "regimen_campo": "Régimen laboral al que pertenece"
            }
        }

        for doc in documents:
            numeral = doc.metadata.numeral
            columns = doc.metadata.columns
            columns = [column.strip() for column in columns]
            data = doc.data

            for row in data:
                row_dict = dict(zip(columns, row))
                print(row_dict)

                if numeral == "Numeral 2.1":
                    nombre = row_dict.get(
                        numeral_columns_map[numeral]["nombre_campo"], "").strip()
                    puesto = row_dict.get(
                        numeral_columns_map[numeral]["puesto_campo"], "").strip()
                    unidad = row_dict.get(
                        numeral_columns_map[numeral]["unidad_campo"], "").strip()
                    #contains
                    if name in nombre or name.lower() in nombre.lower():
                        numeral_21_data.append({
                            "puesto": puesto,
                            "unidad": unidad,
                            "remuneracion": "",
                            "grado": "",
                            "nombre": nombre,
                            "regimen": ""
                        })

                elif numeral == "Numeral 2.2":

                    # buscar todas los elementos

                    nombre = row_dict.get(
                        numeral_columns_map[numeral]["nombre_campo"], "").strip()
                    puesto = row_dict.get(
                        numeral_columns_map[numeral]["puesto_campo"], "").strip()
                    unidad = row_dict.get(
                        numeral_columns_map[numeral]["unidad_campo"], "").strip()
                    if lev.similarity(name, nombre) > 0.4:
                        numeral_21_data.append({
                            "puesto": puesto,
                            "unidad": unidad,
                            "remuneracion": "",
                            "grado": "",
                            "nombre": nombre,
                            "regimen": ""
                        })

                elif numeral == "Numeral 3":
                    puesto = row_dict.get(
                        numeral_columns_map[numeral]["puesto_campo"], "").strip()

                    # buscar en la lista los elementos que tenga el puesto institucional

                    for item in numeral_21_data:
                        if item["puesto"] == puesto:
                            item["remuneracion"] = row_dict.get(
                                numeral_columns_map[numeral]["remuneracion_campo"], "").strip()
                            item["grado"] = row_dict.get(
                                numeral_columns_map[numeral]["grado_campo"], "").strip()

                            item["regimen"] = row_dict.get(
                                numeral_columns_map[numeral]["regimen_campo"], "").strip()

        # Enriquecer los datos de Numeral 2.1 con los adicionales
        for item in numeral_21_data:
            nombre = item["nombre"]
            puesto = item["puesto"]

            if nombre in additional_data:
                item.update(additional_data[nombre])
            elif puesto in additional_data:
                item.update(additional_data[puesto])

        return numeral_21_data
