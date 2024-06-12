from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import serializers
from core.models import Metadata, CSVData
from drf_yasg.utils import swagger_auto_schema
from rest_framework_mongoengine.serializers import DocumentSerializer, EmbeddedDocumentSerializer
from django.http import StreamingHttpResponse
import json
from hermetrics.levenshtein import Levenshtein

class SolicitiesView(APIView):

    class InputSerializerAudience(serializers.Serializer):
        ruc = serializers.CharField()

    @swagger_auto_schema(
        request_body=InputSerializerAudience,
    )
    def post(self, request):

        serializer = self.InputSerializerAudience(data=request.data)
        serializer.is_valid(raise_exception=True)
        ruc = serializer.validated_data['ruc']
        res = CSVData.objects(
            metadata__numeral='Numeral 5',
            metadata__establishment_identification=ruc
        )
        lista = []

        for doc in res:

            for data in doc.data:

                lista.append({
                    "institucion": doc.metadata.establishment_name,
                    "denominacion": data[0],
                    "enlace": data[1],
                    "numero_personas": data[2],
                    "enlace_descarga_formulario": data[3],
                    "enlace_servicio": data[4],
                })

        return Response(lista)
