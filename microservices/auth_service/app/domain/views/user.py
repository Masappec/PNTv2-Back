from rest_framework.generics import ListAPIView, CreateAPIView, UpdateAPIView,DestroyAPIView
from rest_framework.views import APIView
from app.domain.services.user_service import UserService
from app.adapters.impl.user_impl import UserRepositoryImpl
from app.utils import StandardResultsSetPagination
from app.adapters.serializer import UserListSerializer, RegisterSerializer, MessageTransactional,UserCreateAdminSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from app.adapters.impl.role_impl import RoleRepositoryImpl

from app.domain.services.role_service import RoleService
from app.adapters.impl.person_impl import PersonRepositoryImpl
from app.domain.services.person_service import PersonService

class UserListAPI(ListAPIView):
    """
    Endpoint para listar todos los usuarios.

    Args:
       ListAPIView (_type_): The ListAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserListAPI: An instance of the UserListAPI class.
    """
    pagination_class = StandardResultsSetPagination
    serializer_class = UserListSerializer

    def __init__(self):
        """
        The constructor for the UserListAPI class.
        """
        self.user_service = UserService(UserRepositoryImpl())

    def get_queryset(self):
        """
        Get a list of users.

        Returns:
            User: The list of users.
        """
        return self.user_service.get_users()
    
    
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
    

class UserCreateAPI(APIView):
    """
    Endpoint para crear un usuario.

    Args:
       CreateAPIView (_type_): The CreateAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserCreateAPI: An instance of the UserCreateAPI class.
    """
    serializer_class = UserCreateAdminSerializer
    permission_classes = [IsAuthenticated]
    
    output_serializer_class = UserListSerializer

    def __init__(self):
        """
        The constructor for the UserCreateAPI class.
        """
        self.user_service = UserService(UserRepositoryImpl())
        self.role_service = RoleService(RoleRepositoryImpl())
        self.person_service = PersonService(PersonRepositoryImpl())

    @swagger_auto_schema(
        operation_description="Create a user",
        responses={
            201: output_serializer_class,
            400: MessageTransactional
        },
        request_body=serializer_class
        
    )
    def post(self, request, *args, **kwargs):
        """
        Create a user.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        user = None
        person = None
        try:
            
            user = self.user_service.create_user_admin(data)
            person = self.person_service.create_person(data)
            self.person_service.assign_user(person.pk, user.pk)
            for group in data.validated_data['groups']:

                self.user_service.assign_role(user.id, group)
                
            user = self.user_service.get_user_by_id(user.id)
            
            res = MessageTransactional(
                data={
                    'message': 'Usuario creado correctamente',
                    'status': 201,
                    'json':self.output_serializer_class(user).data
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            print(user)
            if user is not None:
                print(user.id)
                self.user_service.delete_permanent_user(user.id)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)
            
            return Response(res.data, status=400)
        
    
    
    
    

class UserUpdate(APIView):
    """
    Endpoint para actualizar un usuario.

    Args:
       UpdateAPIView (_type_): The UpdateAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserUpdate: An instance of the UserUpdate class.
    """
    serializer_class = UserCreateAdminSerializer
    permission_classes = [IsAuthenticated]

    def __init__(self):
        """
        The constructor for the UserUpdate class.
        """
        self.user_service = UserService(UserRepositoryImpl())
        
    def get_queryset(self):
        return self.user_service.get_users()

    def put(self, request, pk, *args, **kwargs):
        """
        Update a user.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        data = self.serializer_class(data=request.data)
        data.is_valid(raise_exception=True)
        user = self.user_service.update_user(pk,data)
        for group in data.validated_data['groups']:
            
            self.user_service.assign_role(user.id, group)
        data = MessageTransactional()
        data.message = 'Usuario actualizado correctamente'
        data.status = 200
        data.data = user
        data.is_valid(raise_exception=True)
        return Response(data.data)



class UserDeactivate(APIView):
    """
    Endpoint para desactivar un usuario.

    Args:
       UpdateAPIView (_type_): The UpdateAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserDeactivate: An instance of the UserDeactivate class.
    """
    permission_classes = [IsAuthenticated]
    
    

    def __init__(self):
        """
        The constructor for the UserDeactivate class.
        """
        self.user_service = UserService(UserRepositoryImpl())
        
    def get_queryset(self):
        return self.user_service.get_users()

    def delete(self, request, pk, *args, **kwargs):
        """
        Deactivate a user.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        user = self.user_service.delete_user(pk)
        return Response({'message': 'Usuario desactivado correctamente'})