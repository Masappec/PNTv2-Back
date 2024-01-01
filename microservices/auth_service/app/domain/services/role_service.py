
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
    
    def role_has_users(self, role_id: int):
        return self.role_repository.role_has_users(role_id)
    
    
    def get_roles_available_by_user(self, user_id: int):
        try:
            return self.role_repository.get_roles_available_by_user(user_id)
        
        except Exception as e:
            print(e)
            raise Exception("Roles no disponibles")
        
    def is_valid_role_and_establishment(self, role_id: int, establishment_id: int):

        """
        The function deletes a user object using the provided user id.

        Args:
            user_id (int): The id of the user to delete.

        Returns:
            User: The user object.
        """
        is_valid = self.role_repository.is_valid_role_and_establishment(role_id, establishment_id)
        if not is_valid:
            raise ValueError("No es posible asignar el rol al usuario de esta institución")