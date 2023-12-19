from app.ports.repositories.permission_repository import PermissionRepository
from app.domain.models import Permission
class PermissionRepositoryImpl(PermissionRepository):
    
    def get_permission(self, permission_id: int):
        return Permission.objects.get(pk=permission_id)
    
    def get_permission_by_name(self, name: str):
        return Permission.objects.get(name=name)
    
    def get_permission_by_code(self, code: str):
        return Permission.objects.get(code=code)
    
    
    def create_permission(self, permission: dict):
        
        return Permission.objects.create(**permission)
    
    
    def update_permission(self, permission_id: int, permission: dict):
        return Permission.objects.filter(pk=permission_id).update(**permission)
    
    def get_permissions(self):
        return Permission.objects.all().exclude(content_type__model__in=['contenttype', 'logentry', 'permission','session'])
    
    