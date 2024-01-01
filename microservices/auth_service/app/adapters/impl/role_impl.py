from app.ports.repositories.role_repository import RoleRepository
from app.domain.models import Role, Permission, User
from django.db import connection

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
        return Role.objects.create(name=role["name"])

    def update_role(self, role_id: int, role: dict):
        role_ = Role.objects.get(pk=role_id)
        role_.name = role["name"]
        role_.save()
        return role_
        

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

        per = Permission.objects.filter(codename__in=permissions)
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


    def delete_permanently(self, role_id: int):
        try:
            return Role.objects.get(pk=role_id).delete()
        except Exception:
            raise Exception("Rol no encontrado")
        
    def role_has_users(self, role_id: int):
        role = Role.objects.get(pk=role_id)
        return role.user_set.count() > 0
    
    
    def get_roles_available_by_user(self, user_id: int):
        role_permissions = {
            'add_user_ciudadano':'Ciudadano',
            'add_user_carga_pnt':'Carga PNT',
            'add_user_supervisora_pnt':'Supervisora PNT',
            'add_user_monitoreo_dpe':'Monitoreo DPE',
            'add_user_monitoreo_pnt_dpe':'Superadministradora PNT DPE'
        }
        
        user = User.objects.get(pk=user_id)
        permissions = user.groups.values_list('permissions__codename', flat=True)
        roles = []
        
        if user.is_superuser:
            for p in role_permissions.keys():
                roles.append(role_permissions[p])
        else:
            for p in permissions:
                if p in role_permissions.keys():
                    roles.append(role_permissions[p])
            
        roles_objects = Role.objects.filter(name__in=roles)
        dict_result = []
        for r in roles_objects:
            dict_result.append({
                'id': r.id,
                'name': r.name,
                'permission_required': role_permissions
            })
            
        
        return dict_result
        
    
    def is_valid_role_and_establishment(self, role_id: int, establishment_id: int):
        
        role = Role.objects.get(pk=role_id)
        if role.name == 'Ciudadano' and establishment_id == 0:
            return True
        
        
        
        with  connection.cursor() as cursor:
            cursor.execute("SELECT * FROM app_admin_establishment WHERE id = %s", [establishment_id])
            row = cursor.fetchone()
            
            if row is None:
                return False
            
         
        return role_id > 0 and establishment_id > 0
            
            