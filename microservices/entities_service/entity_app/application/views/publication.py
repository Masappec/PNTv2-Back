from typing import Any
from rest_framework.generics import ListAPIView
from rest_framework.views import APIView
from django.db.models import Q
from rest_framework.response import Response
from entity_app.utils.pagination import StandardResultsSetPagination
from entity_app.adapters.impl.publication_impl import PublicationImpl
from entity_app.domain.services.publication_service import PublicationService
from entity_app.adapters.serializers import PublicationPublicSerializer

class PublicationsView(ListAPIView):
    """Publication view."""
    
    permission_classes = []
    serializer_class = PublicationPublicSerializer
    pagination_class = StandardResultsSetPagination

    def __init__(self, **kwargs: Any):
        self.sevice = PublicationService(PublicationImpl())

    def get(self):
        """Get queryset."""
        return self.sevice.get_publications()
     