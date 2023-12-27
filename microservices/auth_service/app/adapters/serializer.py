from rest_framework.serializers import ModelSerializer, Serializer, CharField, IntegerField, JSONField, ListField, PrimaryKeyRelatedField
from app.domain.models import User, Permission, Role




class GroupSerializer(ModelSerializer):
        
        class Meta:
            model = Role
            fields = ('id', 'name') 

class UserListSerializer(Serializer):
    id = IntegerField()
    first_name = CharField(max_length=255,source='person.first_name')
    last_name = CharField(max_length=255,source='person.last_name')
    username = CharField(max_length=255)
    email = CharField(max_length=255)
    identification = CharField(max_length=255,source='person.identification')
    phone = CharField(max_length=255,source='person.phone')
    address = CharField(max_length=255,source='person.address')
    city = CharField(max_length=255,source='person.city')
    country = CharField(max_length=255,source='person.country')
    province = CharField(max_length=255,source='person.province')
    groups = ListField(child=GroupSerializer(),source='group')
    





class RegisterSerializer(Serializer):
    
    first_name = CharField(max_length=255)
    last_name = CharField(max_length=255)
    username = CharField(max_length=255)
    email = CharField(max_length=255)
    password = CharField(max_length=255)
    identification = CharField(max_length=255)
    phone = CharField(max_length=255)
    address = CharField(max_length=255)
    city = CharField(max_length=255)
    country = CharField(max_length=255)
    province = CharField(max_length=255)
        



class UserCreateAdminSerializer(Serializer):
    groups = ListField(child=PrimaryKeyRelatedField(queryset=Role.objects.all()))
    first_name = CharField(max_length=255)
    last_name = CharField(max_length=255)
    username = CharField(max_length=255)
    email = CharField(max_length=255)
    identification = CharField(max_length=255)
    phone = CharField(max_length=255)
    address = CharField(max_length=255)
    city = CharField(max_length=255)
    country = CharField(max_length=255)
    province = CharField(max_length=255)
    
    
    

    
    

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
        
class RoleListSerializer(Serializer):
    id = IntegerField()
    name = CharField(max_length=255)
        
        
        

class MessageTransactional(Serializer):
    message = CharField(max_length=255)
    status = IntegerField()
    json = JSONField()