from abc import ABC, abstractmethod

class RoleRepository(ABC):
    
    @abstractmethod
    def get_role(self, role_id: int):
        pass

    @abstractmethod
    def get_role_by_name(self, name: str):
        pass

    @abstractmethod
    def create_role(self, role: dict):
        pass

    @abstractmethod
    def update_role(self, role_id: int, role: dict):
        pass


    
    @abstractmethod
    def get_roles(self):
        pass
    
    @abstractmethod
    def assign_permission(self, role_id: int, permission_id: int):
        pass
    
    def assign_permissions(self, role_id: int, permissions: list):
        pass
    
    
    @abstractmethod
    def remove_permission(self, role_id: int, permission_code: str):
        pass
    
    def remove_permissions(self, role_id: int, permissions: list):
        pass
    
    @abstractmethod
    def get_permissions(self, role_id: int):
        pass
    
    
    @abstractmethod
    def exists_role(self, role_id: int):
        pass
    
    @abstractmethod
    def permission_is_assigned(self, role_id: int, permission_code: str):
        pass
    
    @abstractmethod
    def remove_all_permissions(self, role_id: int):
        pass
    
    @abstractmethod
    def delete_permanently(self, role_id: int):
        pass
    
    @abstractmethod
    def role_has_users(self, role_id: int):
        pass