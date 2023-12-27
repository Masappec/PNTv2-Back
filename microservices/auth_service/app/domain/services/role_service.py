
from app.ports.repositories.role_repository import RoleRepository
class RoleService:
    
    def __init__(self, role_repository: RoleRepository):
        self.role_repository = role_repository
        
    def get_role(self, role_id: int):
        try:
            return self.role_repository.get_role(role_id)
        except Exception:
            raise Exception("Role not found")
        
    
    def get_role_by_name(self, name: str):
        return self.role_repository.get_role_by_name(name)
    
    
    def create_role(self, role: dict):
        rol = self.role_repository.create_role(role)
        self.role_repository.assign_permissions(rol.id, role['permissions'])
        return rol
     
    def update_role(self, role_id: int, role: dict):
        rol = self.role_repository.update_role(role_id, role)
        self.role_repository.remove_all_permissions(rol.id)
        self.role_repository.assign_permissions(rol.id, role['permissions'])
        return rol
    
    def get_roles(self):
        return self.role_repository.get_roles()
    
    def delete_permanently(self, role_id: int):
        return self.role_repository.delete_permanently(role_id)
    
    
    def assign_permissions(self, role_id: int, permissions: list):
        return self.role_repository.assign_permissions(role_id, permissions)