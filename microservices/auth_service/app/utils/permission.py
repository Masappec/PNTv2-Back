
from rest_framework.permissions import BasePermission
from app.domain.models import User

class HasPermission(BasePermission):
    
    
    
    def has_permission(self, request, view):
        
        permission_required = getattr(view, 'permission_required', None)

        
        if request.user.is_superuser:
            return True
        
        user_id = request.user.id
        permissions_list = permission_required.split(',')
        
        if len(permissions_list) > 1:
            is_permited = User.objects.get(id=user_id).groups.filter(permissions__codename__in=permissions_list).exists()
        else:
            is_permited = User.objects.get(id=user_id).groups.filter(permissions__codename=permission_required).exists()
        
        return is_permited

        