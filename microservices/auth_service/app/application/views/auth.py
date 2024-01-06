from rest_framework.generics import CreateAPIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.authentication import JWTAuthentication
from app.adapters.serializer import MessageTransactional, RegisterSerializer, UserLoginSerializer, UserCreateResponseSerializer
from app.domain.services.user_service import UserService
from app.adapters.impl.user_impl import UserRepositoryImpl
from rest_framework.response import Response
from app.adapters.impl.person_impl import PersonRepositoryImpl

from app.domain.services.person_service import PersonService
from app.adapters.impl.role_impl import RoleRepositoryImpl
from app.domain.services.role_service import RoleService
from app.adapters.impl.permission_impl import PermissionRepositoryImpl
from app.domain.services.permission_service import PermissionService

class LoginApiView(TokenObtainPairView):
    """
    metodo que permite la autenticacion de un usuario

    """
    def __init__(self):
        self.user_service = UserService(user_repository=UserRepositoryImpl())
        self.permission_service = PermissionService(permission_repository=PermissionRepositoryImpl())
    
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        
        # Obtén el token de la respuesta
        token = response.data.get('access')

        # Agrega datos adicionales del usuario a la respuesta
        user_data = self.get_user_data(request)
        user_data['user_permissions'] = self.get_permissions_by_user(user_data['id'])
        data = UserLoginSerializer(data=user_data)
        data.is_valid(raise_exception=True)
        response.data['user'] = data.data
        
        
        return response

    def get_user_data(self, request):
        # Aquí deberías implementar la lógica para obtener los datos adicionales del usuario
        # Puedes usar el servicio User o el UserRepository según tu arquitectura
        # Ejemplo: user_service.get_user_data(request.user)
        return self.user_service.get_user_by_username(request.data['username'])

    def get_permissions_by_user(self, id):
        # Agrega tus permisos personalizados aquí
        return self.permission_service.get_permissions_by_user(id)
        
       

    

class RegisterApiView(CreateAPIView):
    """
    Endpoint para crear un usuario.

    Args:
       CreateAPIView (_type_): The CreateAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserCreateAPI: An instance of the UserCreateAPI class.
    """
    
    serializer_class = RegisterSerializer
    permission_classes = []
    
    def __init__(self):
        self.user_service = UserService(user_repository=UserRepositoryImpl())
        self.person_service = PersonService(person_repository=PersonRepositoryImpl())
        self.role_service = RoleService(role_repository=RoleRepositoryImpl())
    
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
        user_obj=None
        try:
            #user_obj = self.user_service.create_user(data)
            
            #person = self.person_service.create_person(data)
            
            #self.person_service.assign_user(person.pk, user_obj.pk)
            
            #role = self.role_service.get_role_by_name('Ciudadano')
            #self.user_service.assign_role(user_obj.pk, role)
            
            #user = self.user_service.get_user_by_id(user_obj.pk)
            data.validated_data['email'] = data.validated_data['username']
            print(data.validated_data)
            
            user = self.user_service.register_cityzen_user(data.validated_data)

            data = UserCreateResponseSerializer(data=user)
            print(user)
            data.is_valid(raise_exception=True)
            res = MessageTransactional(data={
                'message': 'Usuario creado exitosamente',
                'status': 201,
                'json': data.data
            })
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            print("Error", e)
            if person is not None:
                self.person_service.delete_permament_person(person.id)
            if user_obj is not None:
                self.user_service.delete_permanent_user(user_obj.id)
            
                
            res = MessageTransactional(data={
                'message': e.__str__(),
                'status': 400,
                'json': {}
            })
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)
        
        
        