

from entity_app.adapters.impl.file_publication_impl import FilePublicationImpl
from entity_app.domain.services.file_publication_service import FilePublicationService
from entity_app.adapters.serializers import FilePublicationSerializer, MessageTransactional

from rest_framework.generics import ListAPIView
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db.models import Q
from entity_app.utils.pagination import StandardResultsSetPagination
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.permissions import HasPermission

import requests
from django.http import HttpResponse
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response


class FilePublicationCreateView(APIView):

    serializer_class = FilePublicationSerializer

    def __init__(self, **kwargs):

        self.sevice = FilePublicationService(FilePublicationImpl())

    def post(self, request, *args, **kwargs):
        """
        Create a new file publication.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:
            file = request.FILES['url_download']
            serializer = self.serializer_class(data=request.data)

            if serializer.is_valid():
                file_publication = self.sevice.save(
                    **serializer.validated_data, file=file)
                return Response(self.serializer_class(file_publication).data, status=status.HTTP_201_CREATED)

            else:
                res = MessageTransactional().send_errors(
                    serializer.errors, status.HTTP_400_BAD_REQUEST)
                return Response(res, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:

            res = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }

            return Response(res, status=status.HTTP_400_BAD_REQUEST)


class FilePublicationListView(APIView):

    serializer_class = FilePublicationSerializer

    def __init__(self, **kwargs):

        self.sevice = FilePublicationService(FilePublicationImpl())

    def get(self, request, *args, **kwargs):
        """
        Get all file publications.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:

            file_publications = self.sevice.get_all()
            return Response(self.serializer_class(file_publications, many=True).data, status=status.HTTP_200_OK)

        except Exception as e:

            res = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }

            return Response(res, status=status.HTTP_400_BAD_REQUEST)


class FilePublicationDelete(APIView):

    serializer_class = FilePublicationSerializer

    def __init__(self, **kwargs):

        self.sevice = FilePublicationService(FilePublicationImpl())

    def delete(self, request, pk, *args, **kwargs):
        """
        Delete a file publication.

        Args:
            request (object): The request object.
            file_publication_id (int): The file publication id.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:

            self.sevice.delete(pk)
            return Response(status=status.HTTP_204_NO_CONTENT)

        except Exception as e:

            res = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }

            return Response(res, status=status.HTTP_400_BAD_REQUEST)


class FilePublicationListEstablishemtSession(ListAPIView):

    serializer_class = FilePublicationSerializer
    permission_classes = [IsAuthenticated, ]
    pagination_class = StandardResultsSetPagination

    def __init__(self, **kwargs):

        self.sevice = FilePublicationService(FilePublicationImpl())

    def get_queryset(self, request, user_id):
        type = request.query_params.get('type', None)
        numeral_id = request.query_params.get('numeral_id', None)
        return self.sevice.get_by_user_establishment(user_id, type, numeral_id)

    def get(self, request, *args, **kwargs):

        try:

            queryset = self.get_queryset(request, request.user.id)
            search = request.query_params.get('search', None)
            if search is not None:
                queryset = queryset.filter(
                    Q(name__icontains=search) | Q(description__icontains=search))

            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)

        except Exception as e:
            print("Error ", e)
            res = {
                'message': e,
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }

            return Response(res, status=status.HTTP_400_BAD_REQUEST)


class GetFileFromUri(APIView):

    def get(self, request):
        uri = request.query_params.get('uri', None)
        try:
            if uri is None:
                res = {
                    'message': 'Uri is required',
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json': {}
                }
                return Response(res, status=status.HTTP_400_BAD_REQUEST)
            if uri == '':
                res = {
                    'message': 'Uri is required',
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json': {}
                }
                return Response(res, status=status.HTTP_400_BAD_REQUEST)
            file = requests.get(uri)
            if file.status_code == 200:
                content = file.content
                # Devolver el contenido del archivo como una respuesta HTTP directa
                response = HttpResponse(
                    content, content_type='application/octet-stream')
                # Establecer el encabezado Content-Disposition para sugerir al navegador que descargue el archivo
                response['Content-Disposition'] = f'attachment; filename="{
                    uri.split("/")[-1]}"'
                return response
            else:
                res = {
                    'message': 'Error al obtener el archivo',
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json': {}
                }
                return Response(res, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(e )
            res = {
                'message': 'Ocurrio un error al obtener el archivo, verifique la url',
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }
            return Response(res, status=status.HTTP_400_BAD_REQUEST)
