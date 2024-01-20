
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
        
        
    def get(self, request, pk):
        """Get a user by id.
        
        Args:
            request (object): The request object.
            pk (int): The user id.
        
        Returns:
            object: The response object.
        """
        publication = self.sevice.get_publication(pk)
        serializer = PublicationPublicSerializer(publication)
        return Response(serializer.data)
        