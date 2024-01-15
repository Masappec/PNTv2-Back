
from rest_framework.permissions import BasePermission
from django.contrib.auth.models import User

class HasPermission(BasePermission):
    
    
    
    def has_permission(self, request, view):
        
        permission_required = getattr(view, 'permission_required', None)

        
        if request.user.is_superuser:
            return True
        
        user_id = request.user.id
        
        
        return User.objects.get(id=user_id).has_perm(permission_required)

        