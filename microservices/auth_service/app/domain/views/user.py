from rest_framework.generics import ListAPIView, CreateAPIView, UpdateAPIView,DestroyAPIView
from rest_framework.views import APIView
from app.domain.services.user_service import UserService
from app.adapters.impl.user_impl import UserRepositoryImpl
from app.utils import StandardResultsSetPagination
from app.adapters.serializer import UserListSerializer, UserCreateSerializer, MessageTransactional
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response


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
    
    
class UserCreateAPI(CreateAPIView):
    """
    Endpoint para crear un usuario.

    Args:
       CreateAPIView (_type_): The CreateAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserCreateAPI: An instance of the UserCreateAPI class.
    """
    serializer_class = UserCreateSerializer
    permission_classes = [IsAuthenticated]

    def __init__(self):
        """
        The constructor for the UserCreateAPI class.
        """
        self.user_service = UserService(UserRepositoryImpl())

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
        return self.user_service.create_user(request)
    
    
    
    

class UserUpdate(APIView):
    """
    Endpoint para actualizar un usuario.

    Args:
       UpdateAPIView (_type_): The UpdateAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserUpdate: An instance of the UserUpdate class.
    """
    serializer_class = UserCreateSerializer
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
        user = self.user_service.update_user(data.data, pk)
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