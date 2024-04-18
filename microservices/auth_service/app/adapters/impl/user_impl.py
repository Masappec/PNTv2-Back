from app.ports.repositories.user_repository import UserRepository
from app.domain.models import Role, User
from rest_framework_simplejwt.authentication import JWTAuthentication
from django.db.models import Prefetch


class UserRepositoryImpl(UserRepository):
    """
    The UserRepositoryImpl class implements the UserRepository abstract base class.

    Args:
        UserRepository (UserRepository): The UserRepository class is an abstract 
        base class that defines methods for retrieving, creating,
        updating, and deleting user objects.

    """

    def __init__(self):
        """
        The constructor for the UserRepositoryImpl class.
        """
        self.jwt_authentication = JWTAuthentication()

    def register_cityzen_user(self, user: dict):
        user.pop('confirm_password')
        return User.register_citizen_user(**user)

    def get_user(self, user_id: int):
        """
        Get a user by id.

        Args:
            user_id (int): The id of the user to retrieve.

        Returns:
            User: The user object.
        """
        user = User.objects.prefetch_related('groups').prefetch_related(
            'person').filter(pk=user_id).first()

        # return user with groups name

        groups = [{
            'id': group.id,
            'name': group.name
        } for group in user.groups.all()]
        user = user.__dict__
        user['group'] = groups

        return user

    def get_user_object(self, user_id: int):
        """
        Get a user by id.

        Args:
            user_id (int): The id of the user to retrieve.

        Returns:
            User: The user object.
        """
        user = User.objects.get(pk=user_id)
        return user

    def get_users(self):
        """
        Get a list of users.

        Returns:
            User: The user object.
        """
        users = User.objects.prefetch_related(
            'groups').prefetch_related('person')

        # return user with groups name
        for user in users:
            group = [group for group in user.groups.all()]
            # join list to string
            user.group = group
        return users

    def get_user_by_email(self, email: str):
        """
        Get a user by email.

        Args:
            email (str): The email of the user to retrieve.

        Returns:
            User: The user object.
        """

        return User.objects.get(email=email)

    def get_user_by_username(self, username: str):
        """
        Get a user by username.

        Args:
            username (str): The username of the user to retrieve.

        Returns:
            User: The user object.
        """
        user = User.objects.prefetch_related('groups').prefetch_related(
            'person').filter(is_active=True, username=username).first()

        # return user with groups name

        groups = [{
            'id': group.id,
            'name': group.name
        } for group in user.groups.all()]
        user = user.__dict__
        user['group'] = groups

        return user

    def create_user(self, user: dict):
        """
        The function creates a user object using the provided dictionary of user data.

        Args:
            user: The `user` parameter is a dictionary that 
            contains the information needed to create
            a new user. 
            It typically includes fields such as username, email, password, and any other
            required fields for user creation

        Returns: 
            User: The create_user method is returning an instance of the
                  User model that has been created
                  with the provided user dictionary.
        """
        return User.objects.create_user(**user)

    def update_user(self, user_id: int, user: dict):
        """
        The function updates a user object using the provided dictionary of user data.

        Args:
            user_id (int): The id of the user to update.
            user (dict): The `user` parameter is a dictionary that 
            contains the information needed to update
            a user. 
            It typically includes fields such as username, email, password, and any other
            required fields for user update

        Returns: 
            User: The update_user method is returning an instance of the
                  User model that has been updated
                  with the provided user dictionary.
        """
        return User.objects.filter(pk=user_id).update(**user)

    def delete_user(self, user_id: int):
        """
        The function deletes a user object using the provided user id.

        Args:
            user_id (int): The id of the user to delete.

        Returns: 
            User: The delete_user method is returning an instance of the
                  User model that has been deleted
                  with the provided user id.
        """
        return User.objects.filter(pk=user_id).update(is_active=False)

    def login(self, user: dict):
        return self.jwt_authentication.authenticate(**user)

    def assign_role(self, user_id: int, role_id: Role):
        # delete all roles for user
        user_obj = User.objects.get(pk=user_id)
        user_obj.groups.clear()

        if role_id.name.lower().replace(' ', '') == 'superadministradorapntdpe':
            user_obj.is_superuser = True
            user_obj.save()
        return role_id.user_set.add(user_id)

    def delete_permanent_user(self, user_id: int):
        return User.objects.filter(pk=user_id).delete()

    def active_user(self, user_id: int):
        return User.objects.filter(pk=user_id).update(is_active=True)
