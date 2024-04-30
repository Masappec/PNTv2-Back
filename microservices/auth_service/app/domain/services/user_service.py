import json
from app.ports.repositories.user_repository import UserRepository
from app.adapters.serializer import RegisterSerializer, UserCreateAdminSerializer
import random
import string
from app.domain.models import Role
from django.contrib.auth.hashers import make_password
from app.adapters.messaging.events import USER_CREATED, USER_UPDATED
from app.adapters.messaging.channels import CHANNEL_USER
from app.adapters.messaging.publish import Publisher


class UserService:
    """
        The UserService class implements the UserRepository abstract base class.

    """

    def __init__(self, user_repository: UserRepository):
        """
        The constructor for the UserService class.

        Args:
            user_repository (UserRepository): The user_repository parameter is an instance of the
            UserRepository class that will be used to retrieve,
            create, update, and delete user objects.
        """
        self.user_repository = user_repository
        self.publisher = Publisher(CHANNEL_USER)

    def register_cityzen_user(self, user: dict):
        """
        la funcion registra un usuario ciudadano.
        tomando datos de la vista de registro de la aplicacion web

        Args:
            user (dict): el parametro user es un diccionario que contiene los datos del usuario a registrar
            user = {
                "first_name": "string",
                "last_name": "string",
                "username": "string",
                "password": "string",
                "identification": "string",
                "phone": "string",
                "province": "string",
                "gender": "string",
                "age_range": "string",
                "city": "string",
                "race": "string",
                "accept_terms": true,
                "disability": true
            }

        Returns:
            User: Retorna un objeto usuario con los datos del usuario registrado
        """
        user['password'] = make_password(user['password'])

        data = self.user_repository.register_cityzen_user(user)
        return json.loads(data)

    def get_user_by_id(self, user_id: int):
        """
        Obtienes un usuario por id

        Args:
            user_id (int): The id of the user to retrieve.

        Returns:
            User: The user object.
        """
        return self.user_repository.get_user(user_id)

    def get_users(self):
        """
        Get a list of users.

        Returns:
            User: The user object.
        """
        user = self.user_repository.get_users()
        return user

    def generate_password(self):

        # random password

        letters = string.ascii_lowercase
        result_str = ''.join(random.choice(letters) for i in range(10))
        return result_str

    def create_user(self, user: RegisterSerializer):
        """
        The function creates a user object using the provided dictionary of user data.

        Args:
            user (dict): The `user` parameter is a dictionary that

        Returns:
            User: The create_user method is returning an instance of the
                  User model that has been created
                  with the provided user dictionary.
        """
        try:
            data = {
                'username': user.validated_data['username'],
                'email': user.validated_data['username'],
                'password': user.validated_data['password'],
                'first_name': user.validated_data['first_name'],
                'last_name': user.validated_data['last_name'],
            }
            return self.user_repository.create_user(data)
        except Exception as e:
            print("Error", e)
            raise ValueError(
                "Ya existe un usuario con ese correo o nombre de usuario")

    def create_user_admin(self, user: UserCreateAdminSerializer):
        """
        The function creates a user object using the provided dictionary of user data.

        Args:
            user (dict): The `user` parameter is a dictionary that

        Returns:
            User: The create_user method is returning an instance of the
                  User model that has been created
                  with the provided user dictionary.
        """
        data = {
            'username': user.validated_data['username'],
            'email': user.validated_data['username'],
            'password': user.validated_data['password'] if user.validated_data['password'] else self.generate_password(),
            'first_name': user.validated_data['first_name'],
            'last_name': user.validated_data['last_name'],
        }
        user_ = self.user_repository.create_user(data)
        self.publisher.publish({
            'type': USER_CREATED,
            'payload': {
                'user_id': user_.id,
                'establishment_id': user.validated_data['establishment_id']
            }
        })
        return user_

    def update_user(self, user_id: int, user: UserCreateAdminSerializer):
        """
        The function updates a user object using the provided dictionary of user data.

        Args:
            user_id (int): the id of the user to update
            user (dict): The `user` parameter is a dictionary that contains the information needed to update
            a user. It typically includes fields such as username, email, password, and any other
            required fields for user creation

        Returns:
            User: The update_user method is returning an instance of the
                  User model that has been updated
                  with the provided user dictionary.
        """
        data = {
            'username': user.validated_data['username'],
            'email': user.validated_data['username'],
            'first_name': user.validated_data['first_name'],
            'last_name': user.validated_data['last_name'],
        }
        if user.validated_data['password']:
            data['password'] = user.validated_data['password']

        self.publisher.publish({
            'type': USER_UPDATED,
            'payload': {
                'user_id': user_id,
                'establishment_id': user.validated_data['establishment_id']
            }
        })

        return self.user_repository.update_user(user_id, data)

    def delete_user(self, user_id: int):
        """
        The function deletes a user object using the provided user id.

        Args:
            user_id (int): The id of the user to delete.

        Returns:
            User: The user object.
        """
        return self.user_repository.delete_user(user_id)

    def active_user(self, user_id: int):
        """
        The function deletes a user object using the provided user id.

        Args:
            user_id (int): The id of the user to delete.

        Returns:
            User: The user object.
        """
        return self.user_repository.active_user(user_id)

    def get_user_by_email(self, email: str):
        """
        Get a user by email.

        Args:
            email (str): The email of the user to retrieve.

        Returns:
            User: The user object.
        """
        try:
            return self.user_repository.get_user_by_email(email)
        except Exception:
            raise ValueError("User not found")

    def get_user_by_username(self, username: str):
        """
        Get a user by username.

        Args:
            username (str): The username of the user to retrieve.

        Returns:
            User: The user object.
        """
        try:
            return self.user_repository.get_user_by_username(username)
        except Exception as e:
            print(e)
            raise ValueError("User not found")

    def login(self, user: dict):
        """
        Get a user by email.

        Args:
            email (str): The email of the user to retrieve.

        Returns:
            User: The user object.
        """
        try:
            return self.user_repository.login(user)
        except Exception:
            raise ValueError("User or password incorrect")

    def assign_role(self, user_id: int, role_id: Role):
        """
        Assign a role to a user.

        Args:
            user_id (int): The id of the user to assign the role to.
            role_id (int): The id of the role to assign to the user.

        Returns:
            User: The user object.
        """
        try:
            return self.user_repository.assign_role(user_id, role_id)

        except Exception as e:
            print(e)
            raise ValueError("User not found")

    def delete_permanent_user(self, user_id: int):
        """
        The function deletes a user object using the provided user id.

        Args:
            user_id (int): The id of the user to delete.

        Returns:
            User: The user object.
        """
        return self.user_repository.delete_permanent_user(user_id)

    def get_user_object(self, user_id: int):
        """
        Get a user by id.

        Args:
            user_id (int): The id of the user to retrieve.

        Returns:
            User: The user object.
        """
        try:
            return self.user_repository.get_user_object(user_id)
        except Exception:
            raise ValueError("Usuario no encontrado")
