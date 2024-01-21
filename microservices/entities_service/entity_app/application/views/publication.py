from typing import Any
from rest_framework.generics import ListAPIView
from rest_framework.views import APIView
from django.db.models import Q
from rest_framework.response import Response
from entity_app.utils.pagination import StandardResultsSetPagination
from entity_app.adapters.impl.publication_impl import PublicationImpl
from entity_app.domain.services.publication_service import PublicationService
from entity_app.adapters.serializers import PublicationPublicSerializer
from rest_framework.permissions import IsAuthenticated
from entity_app.utils.permissions import HasPermission
from entity_app.adapters.serializers import MessageTransactional
class PublicationsView(ListAPIView):
    """Publication view."""
    
    permission_classes = [IsAuthenticated, HasPermission]
    serializer_class = PublicationPublicSerializer
    pagination_class = StandardResultsSetPagination
    permission_required = 'entity_app.view_publication'

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
            
            
            
            