from typing import Any
from rest_framework.generics import ListAPIView
from drf_yasg.utils import swagger_auto_schema
from rest_framework.views import APIView
from django.db.models import Q
from rest_framework.response import Response
from entity_app.utils.pagination import StandardResultsSetPagination
from entity_app.adapters.impl.publication_impl import PublicationImpl
from entity_app.domain.services.publication_service import PublicationService
from entity_app.adapters.serializers import PublicationPublicSerializer, PublicationCreateSerializer, PublicationUpdateSerializer
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.permissions import HasPermission
from entity_app.adapters.serializers import MessageTransactional

class PublicationsView(ListAPIView):
    """Publication view."""
    
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = PublicationPublicSerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'view_publication'

    def __init__(self, **kwargs: Any):
        self.sevice = PublicationService(PublicationImpl())


        

    def get_queryset(self):
        """Get queryset."""
        return self.sevice.get_publications_by_user_id(self.request.user.id)
    
    
    def get(self, request, *args, **kwargs):
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
            queryset = self.get_queryset()
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
            
            error = MessageTransactional(
                    data={
                        'message': e.__str__(),
                        'status': 400,
                        'json': {} 
                    }
                )
            error.is_valid()
            if error.errors:
                return Response(error.errors)
            return Response(error.data, status=400)
            
class PublicationCreateAPI(APIView):
    """
        Endpoint para crear publicacion.

        Args:
           PublicationCreateAPI (_type_): The PublicationCreateAPI class is a generic view
           that provides a list of objects.

        Returns:
            PublicationCreateAPI: An instance of the PublicationCreateAPI class.
    """
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = PublicationCreateSerializer
    output_serializer_class = PublicationCreateSerializer
    permission_required = 'add_publication'
            
    def __init__(self):
        self.publication_service = PublicationService(PublicationImpl())

    @swagger_auto_schema(
        operation_description="Create a publication",
        response={
            201: output_serializer_class,
            400: MessageTransactional
        },
        request_body=serializer_class,
        #form data
        
    )
    def post(self, request, *args, **kwargs):
        """
        Create a publication.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        data=self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        publication = None

        try:
            
            
            publication = self.publication_service.create_publication(data.data,request.user.id)

            res = MessageTransactional(
                data={ 
                    'message': 'Publicacion creada correctamente',
                    'status': 201,
                    'json': self.output_serializer_class(publication).data
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            print("Error:", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)
        
class PublicationUpdateAPI(APIView):
    """
        Endpoint para crear publicacion.

        Args:
           PublicationUpdateAPI (_type_): The PublicationUpdateAPI class is a generic view
           that provides a list of objects.

        Returns:
            PublicationUpdateAPI: An instance of the PublicationUpdateAPI class.
    """
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = PublicationUpdateSerializer
    output_serializer_class = PublicationPublicSerializer
    permission_required = 'change_publication'
            
    def __init__(self):
        self.publication_service = PublicationService(PublicationImpl())

    @swagger_auto_schema(
        operation_description="Update a publication",
        response={
            201: output_serializer_class,
            400: MessageTransactional
        },
        request_body=serializer_class,
        #form data
        
    )
    def put(self, request, pk):
        """
        Update a publication.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        data=self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        publication = None

        try:
            
            data_save = data.data
            data_save['user_updated_id'] = request.user.id
            publication = self.publication_service.update_publication(pk,data_save)

            res = MessageTransactional(
                data={ 
                    'message': 'Publicacion creada correctamente',
                    'status': 201,
                    'json': self.output_serializer_class(publication).data
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            data={
                'message': str(e),
                'status': 400,
                'json': {}
            }
            
            return Response(data, status=400)
    
    

class PublicatioDetail(APIView):
    
    
    def __init__(self):
        self.publication_service = PublicationService(PublicationImpl())
        
        
    def get(self, request,pk):
        """
        Get a publication detail.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:
            publication = self.publication_service.get_publication_detail_admin(pk,request.user.id)
            serializer = PublicationPublicSerializer(publication)
            return Response(serializer.data)
        except Exception as e:
            
            data={
                'message': str(e),
                'status': 400,
                'json': {}
            }
            
            return Response(data, status=400)
        


class PublicationUpdateState(APIView):
    
    def __init__(self):
        self.publication_service = PublicationService(PublicationImpl())
        
        
    def put(self, request,pk):
        """
        Update state a publication.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:
            publication = self.publication_service.inactivate_activate_publication(pk,request.user.id)
            serializer = PublicationPublicSerializer(publication)
            res = MessageTransactional(
                data={ 
                    'message': 'Publicacion actualizada correctamente',
                    'status': 201,
                    'json': serializer.data
                }
            )
            res.is_valid(raise_exception=True)
            
            return Response(res.data, status=200)
        except Exception as e:
            
            data={
                'message': str(e),
                'status': 400,
                'json': {}
            }
            
            return Response(data, status=400)