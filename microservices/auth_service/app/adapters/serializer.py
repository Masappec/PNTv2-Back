from rest_framework.serializers import ModelSerializer, Serializer, CharField, IntegerField, JSONField, ListField, PrimaryKeyRelatedField
from app.domain.models import User, Permission, Role


class UserListSerializer(ModelSerializer):
    
    class Meta:
        model = User
        exclude = ('password', 'is_superuser', 'is_staff', 'is_active', 'last_login', 'date_joined')


class UserCreateSerializer(ModelSerializer):
    
    
    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'first_name', 'last_name')
        


class UserCreateAdminSerializer(ModelSerializer):
    role_id = PrimaryKeyRelatedField(queryset=Role.objects.all())
    class Meta:
        model = User
        fields = ('username', 'email', 'first_name', 'last_name', 'role_id')


class UserLoginSerializer(ModelSerializer):
    
    class Meta:
        model = User
        
        exclude = ('password', 'is_staff', 'is_active', 'last_login', 'date_joined')
        
        
        
        

class PermissionSerializer(ModelSerializer):
    
    class Meta:
        model = Permission
        fields = ('id', 'name', 'codename', 'content_type')
        


class PermissionListSerializer(ModelSerializer):
    
    class Meta:
        model = Permission
        fields = ('id', 'name', 'codename', 'content_type')

class RoleSerializer(ModelSerializer):
    permissions = PermissionSerializer(many=True)
    
    class Meta:
        model = Role
        fields = ('id', 'name', 'permissions')
        
class RoleCreateSerializer(ModelSerializer):
    permissions = ListField(child=CharField())
        
    class Meta:
        model = Role
        fields = ( 'name', 'permissions')
        
        

class MessageTransactional(Serializer):
    message = CharField(max_length=100)
    status = IntegerField()
    data = JSONField()