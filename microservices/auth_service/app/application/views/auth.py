from base64 import urlsafe_b64encode
from rest_framework.generics import CreateAPIView
from rest_framework_simplejwt.views import TokenObtainPairView

from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils.encoding import force_str, force_bytes
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode

from app.domain.services.person_service import PersonService
from app.adapters.impl.role_impl import RoleRepositoryImpl
from app.domain.services.role_service import RoleService
from app.adapters.impl.permission_impl import PermissionRepositoryImpl
from app.domain.services.permission_service import PermissionService
from app.adapters.serializer import MessageTransactional, RegisterSerializer, UserLoginSerializer, UserCreateResponseSerializer
from app.domain.services.user_service import UserService
from app.adapters.impl.user_impl import UserRepositoryImpl
from app.adapters.impl.person_impl import PersonRepositoryImpl
from shared.tasks.auth_task import auth_send_activate_account_event
from app.utils.tokens import account_activation_token
from app.adapters.messaging.publish import Publisher
from app.adapters.messaging.events import USER_REGISTER
from app.adapters.messaging.channels import CHANNEL_USER
import json


class LoginApiView(TokenObtainPairView):
    """
    metodo que permite la autenticacion de un usuario

    """

    def __init__(self):
        self.user_service = UserService(user_repository=UserRepositoryImpl())
        self.permission_service = PermissionService(
            permission_repository=PermissionRepositoryImpl())

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)

        # Obtén el token de la respuesta
        token = response.data.get('access')

        # Agrega datos adicionales del usuario a la respuesta
        user_data = self.get_user_data(request)
        user_data['user_permissions'] = self.get_permissions_by_user(
            user_data['id'])
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
        self.person_service = PersonService(
            person_repository=PersonRepositoryImpl())
        self.role_service = RoleService(role_repository=RoleRepositoryImpl())
        self.publisher = Publisher(CHANNEL_USER)

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
        user_obj = None
        try:

            user = self.user_service.register_cityzen_user(data.validated_data)

            data = UserCreateResponseSerializer(data=user)
            user_obj = self.user_service.get_user_object(user['id'])
            uidb64 = urlsafe_base64_encode(force_bytes(user_obj.id))
            data.is_valid(raise_exception=True)

            self.publisher.publish({
                'type': USER_REGISTER,
                'payload': {
                    'uidb64': uidb64,
                    'username': data.validated_data['username'],
                    'email': data.validated_data['email'],
                    'token': account_activation_token.make_token(user_obj)
                }
            }
            )
            res = MessageTransactional(data={
                'message': 'Usuario creado exitosamente',
                'status': 201,
                'json': data.data
            })
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            print(e)
            if person is not None:
                self.person_service.delete_permament_person(person.id)
            if user_obj is not None:
                self.user_service.delete_permanent_user(user_obj.id)

            res = MessageTransactional(data={
                'message': e.__str__()[0:100],
                'status': 400,
                'json': {}
            })
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)


class ActivateAccountApiView(APIView):

    permission_classes = []

    def __init__(self):
        self.user_service = UserService(user_repository=UserRepositoryImpl())

    def get(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = self.user_service.get_user_object(uid)
            if user is not None and account_activation_token.check_token(user, token):
                user.is_active = True
                user.save()
                return Response({'message': 'Usuario activado exitosamente'}, status=200)
            else:
                return Response({'message': 'El usuario no existe'}, status=400)
        except Exception as e:
            return Response({'message': e.__str__()}, status=400)
