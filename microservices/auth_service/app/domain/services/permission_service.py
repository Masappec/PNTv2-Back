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
        permissions = self.permission_repository.get_permissions()
        
        for permission in permissions:
            description = permission.name.replace('Can ', 'Puede ')\
                                            .replace('add', 'agregar')\
                                            .replace('change', 'editar')\
                                            .replace('delete', 'eliminar')\
                                            .replace('view', 'ver')\
                                            .replace('_', ' ')\
                                            .replace('group', 'Rol')\
                                            .replace('user', 'Usuario')\
                                            .replace('permission', 'Permiso')\
                                                
            permission.name = description
            
        return permissions
                                            
                                            
        
    
    
    def get_permissions_by_role(self, role_id: int):
        return self.permission_repository.get_permissions_by_role(role_id)
    
    def get_permissions_by_user(self, user_id: int):
        return self.permission_repository.get_permissions_by_user(user_id)
    