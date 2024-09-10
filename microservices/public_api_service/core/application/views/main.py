import os
import zipfile
from io import BytesIO
from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework import serializers
from core.models import TransparencyActive, Numeral, EstablishmentExtended
import urllib.parse
from drf_yasg.utils import swagger_auto_schema

class MainView(APIView):
    class SerializerApi(serializers.Serializer):
        mes = serializers.IntegerField()
        anio = serializers.IntegerField()
        numeral = serializers.CharField()
        institucion = serializers.CharField(allow_blank=True)


    @swagger_auto_schema(
        request_body=SerializerApi,
    )
    def post(self, request):
        serializer = self.SerializerApi(data=request.data)
        serializer.is_valid(raise_exception=True)

        mes = serializer.validated_data['mes']
        anio = serializer.validated_data['anio']
        numeral_name = serializer.validated_data['numeral']
        institucion_identificador = serializer.validated_data['institucion']

        # Filtrar Numeral
        numeral = get_object_or_404(Numeral, name=numeral_name)

        # Filtrar Transparencias Activas por numeral, mes, año e institución
        queryset = TransparencyActive.objects.filter(
            numeral=numeral,
            month=mes,
            year=anio
        )

        if institucion_identificador:
            queryset = queryset.filter(establishment__identification=institucion_identificador)

        # Crear un buffer en memoria para almacenar el archivo ZIP
        zip_buffer = BytesIO()
        # Crear un archivo ZIP
        with zipfile.ZipFile(zip_buffer, 'w') as zip_file:
            for transparency in queryset:
                for file_publication in transparency.files.all():
                    if file_publication.url_download:
                        
                        file_path = '/code/media' + \
                            urllib.parse.unquote(
                                file_publication.url_download.url)

                        print(file_path, os.path.exists(file_path))
                        if os.path.exists(file_path):
                            # Añadir el archivo al ZIP
                            print(file_path,)
                            zip_file.write(
                                file_path, os.path.basename(file_path))

        # Preparar la respuesta HTTP para la descarga del archivo ZIP
        zip_buffer.seek(0)
        response = HttpResponse(zip_buffer, content_type='application/zip')
        response['Content-Disposition'] = 'attachment; filename=files_by_numeral.zip'

        return response
