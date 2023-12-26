from rest_framework.generics import ListAPIView, CreateAPIView
from app.domain.services.role_service import RoleService
from app.adapters.impl.role_impl import RoleRepositoryImpl
from app.adapters.serializer import RoleListSerializer, RoleSerializer, RoleCreateSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Q
class RoleListAPI(ListAPIView):
    serializer_class = RoleListSerializer

    def __init__(self):
        self.role_service = RoleService(role_repository=RoleRepositoryImpl())

    def get_queryset(self):
        return self.role_service.get_roles()

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
                Q(username__icontains=search) | Q(email__icontains=search))

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True) 
        return Response(serializer.data)
        
        
class RoleCreateAPI(CreateAPIView):
    
    serializer_class = RoleCreateSerializer
    
    def __init__(self):
        self.role_service = RoleService(role_repository=RoleRepositoryImpl())
        
    def post(self, request):
        role = self.serializer_class(data=request.data)
        role.is_valid(raise_exception=True)
        res = self.role_service.create_role(role.validated_data)
        return Response(RoleSerializer(res).data, status=status.HTTP_201_CREATED)
    
    
class RoleUpdateAPI(APIView):

    serializer_class = RoleCreateSerializer

    def __init__(self):
        self.role_service = RoleService(role_repository=RoleRepositoryImpl())
        
    def put(self, request, pk):
        role = self.serializer_class(data=request.data)
        role.is_valid(raise_exception=True)
        res = self.role_service.update_role(pk, role.validated_data)
        return Response(RoleSerializer(res).data, status=status.HTTP_200_OK)
        

class RoleDetailAPI(APIView):
    

        
    def __init__(self):
        self.role_service = RoleService(role_repository=RoleRepositoryImpl())
        
    def get(self, request, pk):
        role = self.role_service.get_role(pk)
        return Response(RoleSerializer(role).data, status=status.HTTP_200_OK)