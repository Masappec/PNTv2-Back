from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import serializers
from core.models import Metadata, CSVData
from drf_yasg.utils import swagger_auto_schema
from rest_framework_mongoengine.serializers import DocumentSerializer, EmbeddedDocumentSerializer
from django.http import StreamingHttpResponse
import json
from hermetrics.levenshtein import Levenshtein
import difflib
from unidecode import unidecode
import re

lev = Levenshtein()


def similarity_ratio(word1, word2):
    return difflib.SequenceMatcher(None, word1, word2).ratio()


def remove_accents(text):
    text = unidecode(text)
    # Elimina todos los caracteres que no sean letras
    text = re.sub(r'[^a-zA-Z]', '', text)
    return text


def similarity_percentage(word1, word2):
    return similarity_ratio(word1, word2) * 100


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
        institution = serializers.CharField(allow_blank=True)

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
            "Numeral 2",
            "Numeral 3"
        ]

        try:

            if institution == "":
                res = CSVData.objects(
                    metadata__numeral__in=numerals_list
                )
            else:
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

    def remove_duplicates(self, dict_list):
        seen = set()
        unique_list = []
        for d in dict_list:
            # Convert each dictionary to a frozenset of its items
            # frozenset is hashable and can be added to a set
            tupled = frozenset(d.items())
            if tupled not in seen:
                seen.add(tupled)
                unique_list.append(d)
        return unique_list

    def process_results(self, documents, name):
        numeral_21_data = []
        additional_data = {}

        final_data = []

        numeral_columns_map = {
            "Numeral 2": {
                "nombre_campo": "apellidosynombres",
                "puesto_campo": "puestoinstitucional",
                "unidad_campo": "unidadalaquepertenece"
            },
            "Numeral 3": {
                "puesto_campo": "puestoinstitucional",
                "remuneracion_campo": "remuneracionmensualunificada",
                "grado_campo": "gradojerarquicooescalaalqueperteneceelpuesto",
                "regimen_campo": "regimenlaboralalquepertenece"
            }
        }

        for doc in documents:
            numeral = doc.metadata.numeral
            columns = doc.metadata.columns
            columns = [column.strip() for column in columns]
            columns = [slugify(remove_accents(column)) for column in columns]
            data = doc.data

            for row in data:
                row_dict = dict(zip(columns, row))

                if numeral == "Numeral 2":
                    columna_nombre = remove_accents(
                        numeral_columns_map[numeral]["nombre_campo"])
                    columna_puesto = remove_accents(
                        numeral_columns_map[numeral]["puesto_campo"])

                    columna_unidad = remove_accents(
                        numeral_columns_map[numeral]["unidad_campo"])
                    columna_nombre = slugify(columna_nombre)

                    columna_puesto = slugify(columna_puesto)
                    columna_unidad = slugify(columna_unidad)
                    nombre = row_dict.get(columna_nombre, "").strip()
                    puesto = row_dict.get(columna_puesto, "").strip()
                    unidad = row_dict.get(columna_unidad, "").strip()
                    # contains
                    removed_accents_name = remove_accents(name.lower())
                    removed_accents_nombre = remove_accents(nombre.lower())
                    if removed_accents_name.lower() in removed_accents_nombre.lower():

                        numeral_21_data.append({
                            "puesto": puesto,
                            "unidad": unidad,
                            "remuneracion": "",
                            "grado": "",
                            "nombre": nombre,
                            "regimen": ""
                        })
                    elif removed_accents_nombre.lower() in removed_accents_name.lower():

                        numeral_21_data.append({
                            "puesto": puesto,
                            "unidad": unidad,
                            "remuneracion": "",
                            "grado": "",
                            "nombre": nombre,
                            "regimen": ""
                        })

                elif numeral == "Numeral 3":

                    columna_puesto = remove_accents(
                        numeral_columns_map[numeral]["puesto_campo"])
                    columna_remuneracion = remove_accents(numeral_columns_map[
                        numeral]["remuneracion_campo"])
                    columna_puesto = slugify(columna_puesto)
                    columna_remuneracion = slugify(columna_remuneracion)
                    columna_grado = remove_accents(
                        numeral_columns_map[numeral]["grado_campo"])
                    columna_regimen = remove_accents(
                        numeral_columns_map[numeral]["regimen_campo"])
                    columna_grado = slugify(columna_grado)
                    columna_regimen = slugify(columna_regimen)

                    puesto = row_dict.get(columna_puesto, "").strip()

                    # buscar en la lista los elementos que tenga el puesto institucional

                    for item in numeral_21_data:
                        if item["puesto"] == puesto:
                            item["remuneracion"] = row_dict.get(
                                columna_remuneracion, "").strip()
                            item["grado"] = row_dict.get(
                                columna_grado, "").strip()

                            item["regimen"] = row_dict.get(
                                columna_regimen, "").strip()

                        else:
                            removed_accents_puesto = remove_accents(
                                puesto.lower())
                            removed_accents_puesto_item = remove_accents(
                                item["puesto"].lower())
                            if similarity_percentage(removed_accents_puesto, removed_accents_puesto_item) > 40:
                                item["remuneracion"] = row_dict.get(
                                    columna_remuneracion, "").strip()
                                item["grado"] = row_dict.get(
                                    columna_grado, "").strip()

                                item["regimen"] = row_dict.get(
                                    columna_regimen, "").strip()

                        final_data.append(item)

        if final_data.__len__() == 0:
            for item in numeral_21_data:
                final_data.append(item)

        final_data = self.remove_duplicates(final_data)
        return final_data
