from .role_permissions import RolePermissionDataService


class ConfigService:

    def __init__(self):
        self.role_permission_service = RolePermissionDataService()

    def asign_permission_to_citizen(self):
        self.role_permission_service.asign_permission_to_citizen()
