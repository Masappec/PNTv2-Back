
from typing import Any
from rest_framework.generics import ListAPIView
from rest_framework.views import APIView
from entity_app.adapters.impl.publication_impl import PublicationImpl

from entity_app.domain.services.publication_service import PublicationService
from entity_app.utils.pagination import StandardResultsSetPagination
from django.db.models import Q
from rest_framework.response import Response
from entity_app.adapters.serializers import PublicationPublicSerializer
from entity_app.utils.permissions import IsPublicPublication
from entity_app.adapters.serializers import MessageTransactional
from entity_app.adapters.impl.transparency_active_impl import TransparencyActiveImpl
from entity_app.adapters.impl.transparency_colaborative_impl import TransparencyColaborativeImpl
from entity_app.adapters.impl.transparency_focus_impl import TransparencyFocalImpl
from entity_app.domain.services.transparency_active_service import TransparencyActiveService
from entity_app.domain.services.transparency_colaborative_service import TransparencyColaborativeService
from entity_app.domain.services.transparency_focus_service import TransparencyFocusService

class PublicationPublicView(ListAPIView):
    """Publication view."""
    
    permission_classes = []
    serializer_class = PublicationPublicSerializer
    
    pagination_class = StandardResultsSetPagination
    def __init__(self, **kwargs: Any):
        
        self.sevice = PublicationService(PublicationImpl())
        

    def get_queryset(self):
        """Get queryset."""
        return self.sevice.get_publications_transparency_active()
    
    
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
        queryset = self.get_queryset()
        search = request.query_params.get('search', None)
        if search is not None:
            queryset = queryset.filter(
                Q(name__icontains=search) | Q(description__icontains=search))
            
        id_establishment = request.query_params.get('id_establishment', None)
        if id_establishment is not None:
            queryset = queryset.filter(
                establishment__id=id_establishment)

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    
class PublicationDetail(APIView):
    
    permission_classes = [IsPublicPublication]
    def __init__(self, **kwargs: Any):
        
        self.sevice = PublicationService(PublicationImpl())
        
        
    def get(self, request, slug):
        """Get a user by id.
        
        Args:
            request (object): The request object.
            pk (int): The user id.
        
        Returns:
            object: The response object.
        """
        try:
            publication = self.sevice.get_publication_by_slug(slug)
            serializer = PublicationPublicSerializer(publication)
            return Response(serializer.data)
        except Exception as e:
            res = MessageTransactional(
                data={
                    'message': e.__str__(),
                    'status': 400,
                    'json':{} 
                }
            )
            
            res.is_valid()
            
            if res.errors:
                return Response(res.errors, status=400)
            
            return Response(res.data, status=400)
        


class MonthForTransparency(APIView):
    
    permission_classes = []
    def __init__(self, **kwargs: Any):
        
        self.sevice = TransparencyActiveService(TransparencyActiveImpl())
        self.service_tf = TransparencyFocusService(TransparencyFocalImpl())
        self.service_tc = TransparencyColaborativeService(TransparencyColaborativeImpl())
        
        
    def get(self, request):
        """Get a user by id.
        
        Args:
            request (object): The request object.
            pk (int): The user id.
        
        Returns:
            object: The response object.
        """
        type = request.query_params.get('type', None)
        year = request.query_params.get('year', None)
        establishment_id = request.query_params.get('establishment_id', None)
        
        if type == 'A':
            response = self.sevice.get_months_by_year(year, establishment_id)
        elif type == 'F':
            response = self.service_tf.get_months_by_year(year, establishment_id)
        elif type == 'C':
            response = self.service_tc.get_months_by_year(year, establishment_id)
            
        return Response(response)