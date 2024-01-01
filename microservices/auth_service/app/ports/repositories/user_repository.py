from abc import ABC, abstractmethod

from app.domain.models import Role


class UserRepository(ABC):
    """
    The UserRepostory class is an abstract base class that defines methods for retrieving, creating,
    updating, and deleting user objects.
    Args:
        ABC (_type_): The ABC class is a helper class that is used to create abstract base classes.

    """

    @abstractmethod
    def get_user(self, user_id: int):
        """
        The function `get_user` is an abstract method that takes an integer `user_id` as input and does
        not have an implementation.
        
        :param user_id: An integer representing the unique identifier of a user
        :type user_id: int
        """
        pass

    @abstractmethod
    def get_user_by_email(self, email: str):
        pass
    
    def get_user_by_username(self, username: str):
        pass

    @abstractmethod
    def create_user(self, user: dict):
        pass
 
    @abstractmethod
    def update_user(self, user_id: int, user: dict):
        pass

    @abstractmethod
    def delete_user(self, user_id: int):
        pass
    
    @abstractmethod
    def get_users(self):
        pass

        
    def login(self, user: dict):
        pass
    @abstractmethod
    def assign_role(self, user_id: int, role_id: Role):
        pass
    @abstractmethod
    def delete_permanent_user(self, user_id: int):
        pass
    
