
from rest_framework.views import APIView
from rest_framework.generics import ListAPIView, CreateAPIView, UpdateAPIView,DestroyAPIView

from app_admin.adapters.serializer import EstablishmentListSerializer
from app_admin.utils.pagination import StandardResultsSetPagination
from app_admin.domain.service.establishment_service import EstablishmentService
from app_admin.adapters.impl.establishment_impl import EstablishmentRepositoryImpl
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q

class EstablishmentListAPI(ListAPIView):
    
    pagination_class = StandardResultsSetPagination
    serializer_class = EstablishmentListSerializer
    

    def __init__(self):
        """
        The constructor for the UserListAPI class.
        """
        self.user_service = EstablishmentService(EstablishmentRepositoryImpl())

    def get_queryset(self):
        """
        Get a list of users.

        Returns:
            User: The list of users.
        """
        return self.user_service.get_establishments()
    
    
    #search by username
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
            queryset = queryset.filter(Q(username__icontains=search) | Q(email__icontains=search))
        
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    


