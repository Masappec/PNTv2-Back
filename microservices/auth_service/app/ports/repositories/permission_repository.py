
from abc import ABC, abstractmethod

    

class PermissionRepository(ABC):
    
    @abstractmethod
    def get_permission(self, permission_id: int):
        pass

    @abstractmethod
    def get_permission_by_name(self, name: str):
        pass
    
    def get_permission_by_code(self, code: str):
        pass

    @abstractmethod
    def create_permission(self, permission: dict):
        pass

    @abstractmethod
    def update_permission(self, permission_id: int, permission: dict):
        pass


    
    @abstractmethod
    def get_permissions(self):
        pass
    
    @abstractmethod
    def get_permissions_by_role(self, role_id: int):
        pass
    
    @abstractmethod
    def get_permissions_by_user(self, user_id: int):
        pass
    
