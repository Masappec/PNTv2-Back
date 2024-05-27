import json
from rest_framework.generics import ListAPIView, CreateAPIView, UpdateAPIView, DestroyAPIView
from rest_framework.views import APIView
from app.domain.services.user_service import UserService
from app.adapters.impl.user_impl import UserRepositoryImpl
from app.utils import StandardResultsSetPagination
from app.adapters.serializer import UserListSerializer, RegisterSerializer, MessageTransactional, UserCreateAdminSerializer, UserCreateResponseSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from app.adapters.impl.role_impl import RoleRepositoryImpl
from app.utils.permission import HasPermission

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
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'view_user'

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

    # search by username

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
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'auth.add_user'
    output_serializer_class = UserCreateResponseSerializer

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
        Crea un usuario.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        user = None
        person = None
        try:
            data = self.serializer_class(data=request.data)
            data.is_valid(raise_exception=True)
            find_user = self.user_service.get_user_by_email(
                data.validated_data['email'])
            if find_user:
                raise ValueError('Este correo ya está en uso')

            find_user = self.user_service.get_user_by_username(
                data.validated_data['username'])
            if find_user:
                raise ValueError('Este nombre de usuario ya está en uso')
            # crea el usuario
            user = self.user_service.create_user_admin(data)

            # crea los datos de la persona
            person = self.person_service.create_person(data)

            # asigna el usuario a la persona
            self.person_service.assign_user(person.pk, user.pk)

            # asigna el rol al usuario
            for group in data.validated_data['groups']:
                self.user_service.assign_role(user.id, group)

            group_first = user.groups.all().first(
            ).id if user.groups.all().first() is not None else 0

            # verifica si el rol y el establecimiento son validos
            self.role_service.is_valid_role_and_establishment(
                group_first, data.validated_data['establishment_id'])

            # obtiene el usuario con los datos de la persona

            # serializa la respuesta
            data_response = self.output_serializer_class(data={
                'id': user.id,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'username': user.username,
                'email': user.email,
                'identification': person.identification,
                'phone': person.phone,
                'city': person.city,
                'country': person.country,
                'province': person.province,
                'group': [{
                    'id': group.id,
                    'name': group.name
                } for group in user.groups.all()],
            })
            data_response.is_valid(raise_exception=True)
            res = MessageTransactional(
                data={
                    'message': 'Usuario creado correctamente',
                    'status': 201,
                    'json': data_response.data
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            print("Error:", str(e))
            if user is not None:

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
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'auth.change_user'
    output_serializer_class = UserCreateResponseSerializer

    def __init__(self):
        """
        The constructor for the UserUpdate class.
        """
        self.user_service = UserService(UserRepositoryImpl())
        self.role_service = RoleService(RoleRepositoryImpl())
        self.person_service = PersonService(PersonRepositoryImpl())

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
        user = None
        person = None
        init_rol = None
        try:
            data = self.serializer_class(data=request.data)
            data.is_valid(raise_exception=True)

            user = self.user_service.get_user_object(pk)
            init_rol = user.groups.all().first()
            for group in data.validated_data['groups']:
                self.user_service.assign_role(pk, group)

            group_first = user.groups.all().first(
            ).id if user.groups.all().first() is not None else 0

            # actualiza el usuario
            user_update = self.user_service.update_user(pk, data)

            person = self.person_service.update_person_by_user_id(pk, data)

            group_first = user.groups.all().first(
            ).id if user.groups.all().first() is not None else 0

            # verifica si el rol y el establecimiento son validos
            self.role_service.is_valid_role_and_establishment(
                group_first, data.validated_data['establishment_id'])

            data_response = self.output_serializer_class(data={
                'id': user.id,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'username': user.username,
                'email': user.email,
                'identification': person.identification,
                'phone': person.phone,
                'city': person.city,
                'country': person.country,
                'province': person.province,
                'group': [{
                    'id': group.id,
                    'name': group.name
                } for group in user.groups.all()],
            })
            data_response.is_valid(raise_exception=True)
            res = MessageTransactional(
                data={
                    'message': 'Usuario actualizado correctamente',
                    'status': 200,
                    'json': data_response.data
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=200)
        except Exception as e:
            print("Error: ", str(e))
            # rollback
            if user is not None:
                if init_rol.id != group_first:
                    self.user_service.assign_role(pk, init_rol)

            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)

            return Response(res.data, status=400)


class UserDetail(APIView):
    """
    Endpoint para obtener un usuario.

    Args:
       RetrieveAPIView (_type_): The RetrieveAPIView class is a generic view 
       that provides a list of objects.

    Returns:
        UserDetail: An instance of the UserDetail class.
    """
    serializer_class = UserCreateResponseSerializer
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'auth.view_user'

    def __init__(self):
        """
        The constructor for the UserDetail class.
        """
        self.user_service = UserService(UserRepositoryImpl())
        self.person_service = PersonService(PersonRepositoryImpl())

    def get_queryset(self):
        return self.user_service.get_users()

    def get(self, request, pk, *args, **kwargs):
        """
        Get a user by id.

        Args:
            request (object): The request object.
            pk (int): The id of the user to retrieve.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:
            user = self.user_service.get_user_object(pk)
            person = self.person_service.get_person_by_userid(user.id)

            data_response = self.serializer_class(data={
                'id': user.id,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'username': user.username,
                'email': user.email,
                'identification': person.identification,
                'phone': person.phone,
                'city': person.city,
                'country': person.country,
                'province': person.province,
                'group': [{
                    'id': group.id,
                    'name': group.name
                } for group in user.groups.all()],
            })

            data_response.is_valid(raise_exception=True)
            return Response(data_response.data, status=200)

        except Exception as e:
            print("Error: ", str(e))

            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)

            return Response(res.data, status=400)


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
    permission_classes = [IsAuthenticated, HasPermission]
    permission_required = 'auth.delete_user'

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
        user_selected = self.user_service.get_user_object(pk)
        if user_selected.is_superuser:
            return Response({'message': 'No se puede desactivar un usuario administrador'}, status=400)

        if user_selected.is_active:
            self.user_service.delete_user(pk)
            return Response({'message': 'Usuario desactivado correctamente'}, status=202)

        self.user_service.active_user(pk)
        return Response({'message': 'Usuario Activado correctamente'}, status=200)
