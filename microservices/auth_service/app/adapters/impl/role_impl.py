from app.ports.repositories.role_repository import RoleRepository
from app.domain.models import Role, Permission


class RoleRepositoryImpl(RoleRepository):
    """
    Implementation of the RoleRepository interface.
    Provides methods to interact with the Role model in the database.
    """

    def get_role(self, role_id: int):
        return Role.objects.get(pk=role_id)

    def get_role_by_name(self, name: str):
        return Role.objects.get(name=name)

    def create_role(self, role: dict):
        return Role.objects.create(**role)

    def update_role(self, role_id: int, role: dict):
        return Role.objects.filter(pk=role_id).update(**role)

    def get_roles(self):
        return Role.objects.all()

    def assign_permission(self, role_id: int, permission_id: int):
        return Role.objects.get(pk=role_id).permissions.add(permission_id)

    def assign_permissions(self, role_id: int, permissions: list):
        """
        Assigns permissions to a role based on permission codes.

        Args:
            role_id (int): The ID of the role.
            permissions (list): List of permission codes to assign.

        Returns:
            Role: The updated role object.
        """
        role = self.get_role(role_id)

        per = Permission.objects.filter(code__in=permissions)
        for p in per:
            role.permissions.add(p)

        return role

    def remove_permission(self, role_id: int, permission_code: str):
        return Role.objects.get(pk=role_id).permissions.remove(
            Permission.objects.get(code=permission_code)
        )

    def remove_permissions(self, role_id: int, permissions: list):
        role = self.get_role(role_id)

        per = Permission.objects.filter(code__in=permissions)
        for p in per:
            role.permissions.remove(p)

        return role

    def get_permissions(self, role_id: int):
        return Role.objects.get(pk=role_id).permissions.all()

    def exists_role(self, role_id: int):
        return Role.objects.filter(pk=role_id).exists()

    def permission_is_assigned(self, role_id: int, permission_code: str):
        return Role.objects.get(pk=role_id).permissions.filter(code=permission_code).exists()
    
    def remove_all_permissions(self, role_id: int):
        return Role.objects.get(pk=role_id).permissions.clear()
