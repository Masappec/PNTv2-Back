from app.ports.repositories.permission_repository import PermissionRepository


class PermissionService:

    def __init__(self, permission_repository: PermissionRepository):
        self.permission_repository = permission_repository

    
    def get_permission(self, permission_id: int):
        return self.permission_repository.get_permission(permission_id)
    
    def get_permission_by_name(self, name: str):
        return self.permission_repository.get_permission_by_name(name)
    
    def get_permission_by_code(self, code: str):
        return self.permission_repository.get_permission_by_code(code)
    
    
    def create_permission(self, permission: dict):
        return self.permission_repository.create_permission(permission)
    
    
    def update_permission(self, permission_id: int, permission: dict):
        return self.permission_repository.update_permission(permission_id, permission)
    
    
    def get_permissions(self):
        return self.permission_repository.get_permissions()