from rest_framework.generics import CreateAPIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.authentication import JWTAuthentication
from app.adapters.serializer import UserCreateSerializer, UserLoginSerializer, UserListSerializer
from app.domain.services.user_service import UserService
from app.adapters.impl.user_impl import UserRepositoryImpl
from rest_framework.response import Response

class LoginApiView(TokenObtainPairView):
    """
    metodo que permite la autenticacion de un usuario

    """
    def __init__(self):
        self.user_service = UserService(user_repository=UserRepositoryImpl())
    
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        
        # Obtén el token de la respuesta
        token = response.data.get('access')

        # Agrega datos adicionales del usuario a la respuesta
        user_data = self.get_user_data(request)
        response.data['user'] = UserLoginSerializer(user_data).data

        return response

    def get_user_data(self, request):
        # Aquí deberías implementar la lógica para obtener los datos adicionales del usuario
        # Puedes usar el servicio User o el UserRepository según tu arquitectura
        # Ejemplo: user_service.get_user_data(request.user)
        return self.user_service.get_user_by_username(request.data['username'])

        
       

    

class RegisterApiView(CreateAPIView):
    """
    Endpoint para crear un usuario.

    Args:
       CreateAPIView (_type_): The CreateAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserCreateAPI: An instance of the UserCreateAPI class.
    """
    
    serializer_class = UserCreateSerializer
    permission_classes = []
    
    def __init__(self):
        self.user_service = UserService(user_repository=UserRepositoryImpl())
    
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
        
        
        user = self.user_service.create_user(data.validated_data)
        
        return Response(UserListSerializer(user).data)
        
        
        