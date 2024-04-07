from app.domain.services.permission_service import PermissionService
from app.adapters.impl.permission_impl import PermissionRepositoryImpl
from app.domain.services.role_service import RoleService
from app.adapters.impl.role_impl import RoleRepositoryImpl


class RolePermissionDataService:

    def __init__(self) -> None:
        self.permissions_service = PermissionService(
            PermissionRepositoryImpl())
        self.role_service = RoleService(RoleRepositoryImpl())

    def asign_permission_to_citizen(self):

        role = self.role_service.get_role_by_name('Ciudadano')
        permissions = self.permissions_service.get_permissions_by_role(role.id)

        if permissions.count() == 0:

            self.role_service.assign_permissions(
                role.id, ['add_solicity', 'change_solicity', 'view_solicity'])
