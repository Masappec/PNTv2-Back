from rest_framework.serializers import ModelSerializer, Serializer, CharField, BooleanField, IntegerField, JSONField, ListField, PrimaryKeyRelatedField
from app.domain.models import User, Permission, Role




class GroupSerializer(ModelSerializer):
        
        class Meta:
            model = Role
            fields = ('id', 'name') 

class UserCreateResponseSerializer(Serializer):
    id = IntegerField()
    first_name = CharField(max_length=255,source='person.first_name',allow_null=True,allow_blank=True)
    last_name = CharField(max_length=255,source='person.last_name',allow_null=True,allow_blank=True)
    username = CharField(max_length=255)
    email = CharField(max_length=255)
    identification = CharField(max_length=255,source='person.identification',allow_null=True,allow_blank=True)
    phone = CharField(max_length=255,source='person.phone',allow_null=True,allow_blank=True)
    city = CharField(max_length=255,source='person.city',allow_null=True,allow_blank=True)
    country = CharField(max_length=255,source='person.country',allow_null=True,allow_blank=True)
    province = CharField(max_length=255,source='person.province',allow_null=True,allow_blank=True)
    group = ListField(child=JSONField(),allow_null=True)


class UserListSerializer(Serializer):
    id = IntegerField()
    first_name = CharField(max_length=255,source='person.first_name')
    last_name = CharField(max_length=255,source='person.last_name')
    username = CharField(max_length=255)
    email = CharField(max_length=255)
    identification = CharField(max_length=255,source='person.identification')
    phone = CharField(max_length=255,source='person.phone')
    city = CharField(max_length=255,source='person.city')
    country = CharField(max_length=255,source='person.country')
    province = CharField(max_length=255,source='person.province')
    group = ListField(child=GroupSerializer(),allow_null=True)
    is_active = BooleanField()




class RegisterSerializer(Serializer):
    
    first_name = CharField(max_length=255)
    last_name = CharField(max_length=255)
    username = CharField(max_length=255)
    password = CharField(max_length=255)
    identification = CharField(max_length=255)
    phone = CharField(max_length=255)
    province = CharField(max_length=255)
    gender = CharField(max_length=255)
    age_range = CharField(max_length=255)
    city = CharField(max_length=255)
    race = CharField(max_length=255)
    accept_terms = BooleanField()
    



class UserCreateAdminSerializer(Serializer):
    groups = ListField(child=PrimaryKeyRelatedField(queryset=Role.objects.all()))
    first_name = CharField(max_length=255)
    last_name = CharField(max_length=255)
    username = CharField(max_length=255)
    password = CharField(max_length=255,allow_null=True,allow_blank=True)
    identification = CharField(max_length=255)
    phone = CharField(max_length=255,allow_null=True,allow_blank=True)
    city = CharField(max_length=255,allow_null=True,allow_blank=True)
    province = CharField(max_length=255,allow_null=True,allow_blank=True)
    job = CharField(max_length=255,allow_null=True,allow_blank=True)
    establishment_id = IntegerField(allow_null=True)
    race = CharField(max_length=255,allow_null=True,allow_blank=True)
    age_range = CharField(max_length=255,allow_null=True,allow_blank=True)
    accept_terms = BooleanField(default=True,allow_null=True)
    
    

    
    

class UserLoginSerializer(Serializer):

    id = IntegerField()
    is_superuser = BooleanField()
    username = CharField(max_length=255)
    first_name = CharField(max_length=255,allow_null=True,allow_blank=True)
    last_name = CharField(max_length=255,allow_null=True,allow_blank=True)
    email = CharField(max_length=255)
    group = ListField(child=JSONField())
    user_permissions = ListField(child=JSONField())
    
        

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
        
class RoleCreateSerializer(Serializer):
    permissions = ListField(child=CharField())
    name = CharField(max_length=255)

        
class RoleListSerializer(Serializer):
    id = IntegerField()
    name = CharField(max_length=255)
        
        
        

class MessageTransactional(Serializer):
    message = CharField(max_length=255)
    status = IntegerField()
    json = JSONField()
    
    

class RoleListAvailableSerializer(Serializer):
    id = IntegerField()
    name = CharField(max_length=255)
    permission_required = CharField(max_length=255)