from app.ports.repositories.user_repository import UserRepository


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

    def get_user_by_id(self, user_id: int):
        """
        Get a user by id.

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
        return self.user_repository.get_users()

    def create_user(self, user: dict):
        """
        The function creates a user object using the provided dictionary of user data.

        Args:
            user (dict): The `user` parameter is a dictionary that

        Returns:
            User: The create_user method is returning an instance of the
                  User model that has been created
                  with the provided user dictionary.
        """
        return self.user_repository.create_user(user)

    def update_user(self, user_id: int, user: dict):
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
        return self.user_repository.update_user(user_id, user)

    def delete_user(self, user_id: int):
        """
        The function deletes a user object using the provided user id.

        Args:
            user_id (int): The id of the user to delete.

        Returns:
            User: The user object.
        """
        return self.user_repository.delete_user(user_id)

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
        except Exception:
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
