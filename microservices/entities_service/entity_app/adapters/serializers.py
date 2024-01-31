from rest_framework import serializers
from entity_app.domain.models.publication import Attachment, Publication,Tag, FilePublication
from entity_app.domain.models.type_formats import TypeFormats
from microservices.entities_service.entity_app.domain.models.solicity import Solicity
import datetime

class TagSerializer(serializers.ModelSerializer):
    """Tag serializer."""
    class Meta:
        """Meta class."""
        model = Tag
        fields = (
            'id',
            'name',
            'description',
        )
        
        read_only_fields = ('id','description')


class FilePublicationSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = FilePublication
        fields = (
            'id',
            'name',
            'description',
            'url_download',
        )
        
        read_only_fields = ('id', 'url_download')
        
class TypeFormatsSerializer(serializers.ModelSerializer):
        
        class Meta:
            model = TypeFormats
            fields = (
                'id',
                'name',
                'description',
            )

class PublicationCreateSerializer(serializers.Serializer):
    name = serializers.CharField()
    description = serializers.CharField()
    group_dataset = serializers.ListField(child=serializers.IntegerField())
    file_publication = serializers.ListField(child=serializers.IntegerField())
    type_publication = serializers.CharField(source='type_publication.name')
    notes = serializers.CharField(allow_blank=True, allow_null=True)
    attachment = serializers.ListField(child=serializers.IntegerField())


class PublicationUpdateSerializer(serializers.Serializer):
    name = serializers.CharField()
    description = serializers.CharField()
    group_dataset = serializers.ListField(child=serializers.IntegerField())
    file_publication = serializers.ListField(child=serializers.IntegerField())
    type_publication = serializers.CharField(source='type_publication.name')
    notes = serializers.CharField(allow_blank=True, allow_null=True)
    attachment = serializers.ListField(child=serializers.IntegerField())



class AttachmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attachment
        
        fields = (
            'id',
            'name',
            'description',
            'url_download',
        )
        
        read_only_fields = ('id',)





class PublicationPublicSerializer(serializers.Serializer):
    """Publication serializer."""
    id = serializers.IntegerField()
    name = serializers.CharField()
    description = serializers.CharField()
    is_active = serializers.BooleanField()
    establishment = serializers.IntegerField(source='establishment.id')
    establishment_name = serializers.CharField(source='establishment.name')
    type_publication = serializers.CharField(source='type_publication.name')
    tag = TagSerializer(many=True)
    type_format = TypeFormatsSerializer(many=True)
    file_publication = FilePublicationSerializer(many=True)
    created_at = serializers.DateTimeField()
    updated_at = serializers.DateTimeField()
    deleted_at = serializers.DateTimeField()
    user_created = serializers.SerializerMethodField(method_name='get_user_created')
    email_created = serializers.CharField(source='user_created.email', read_only=True, required=False, allow_null=True)
    user_updated = serializers.CharField(source='user_updated.username', read_only=True, required=False, allow_null=True)
    user_deleted = serializers.CharField(source='user_deleted.username', read_only=True, required=False, allow_null=True)
    slug = serializers.SlugField(allow_blank=True, allow_unicode=True,allow_null=True)
    attachment = AttachmentSerializer(many=True)
    notes = serializers.CharField(allow_blank=True, allow_null=True)
    class Meta:
        """Meta class."""
        model : 'Publication'
        fields = '__all__'
        
    def to_representation(self, instance):
        """To representation."""
        representation = super().to_representation(instance)
        for x, i in enumerate(instance.file_publication.all()):
            url_download = i.url_download.url
            
            representation['file_publication'][x]['url_download'] = url_download
        
        return representation
    
    def get_user_created(self, obj):
        if obj.user_created is None:
            return ''
        return obj.user_created.first_name + ' ' + obj.user_created.last_name


class MessageTransactional(serializers.Serializer):
    message = serializers.CharField(max_length=1000)
    status = serializers.IntegerField()
    json = serializers.JSONField()


    def send_errors(self, errors,status):
        e = ""
        for error in errors:
            e += error[0] + ", "
            
                        
        
        return MessageTransactional(message=e, status=status, json=errors).data
    
    
class SolicitySerializer(serializers.ModelSerializer):
    """Solicity serializer"""
    id=serializers.IntegerField();
    title=serializers.CharField();
    text=serializers.CharField();
    establishment = serializers.IntegerField(source='establishment.id')
    establishment_name = serializers.CharField(source='establishment.name')
    user = serializers.IntegerField()
    is_active = serializers.IntegerField();
    status=serializers.CharField();
    expiry_date=serializers.DateTimeField();
    have_extension = serializers.BooleanField();
    id_manual = serializers.BooleanField();

class SolicityCreateSerializer(serializers.ModelSerializer):
    """Solicity create serializer"""
    establishment_id = serializers.IntegerField();
    title=serializers.CharField();
    description=serializers.CharField();
    expiry_date=datetime.date() + datetime.timedelta(days=15)

class SolicityCreateResponseSerializer(serializers.ModelSerializer):
    """Solicity Create Response serializer."""

    id_solicitud = serializers.IntegerField()
    text = serializers.CharField()
    files = serializers.ListField(child=serializers.IntegerField())
    attachment = serializers.ListField(child=serializers.IntegerField())
    category_id = serializers.IntegerField();

class SolicitySerializer(serializers.ModelSerializer):
    
    class Meta:
        
        model = Solicity
        fields = (
            'id',
            'text',
            'establishment',
            'user',
            'is_active',
            'status',
            'expiry_date',
            'have_extension',
            'is_manual',
        )
        
        read_only_fields = ('id', 'is_active', 'status', 'have_extension', 'is_manual')



class CreateExtensionSerializer(serializers.Serializer):
    
    motive = serializers.CharField()
    solicity = SolicitySerializer()
    
    
class CreateInsistencySerializer(serializers.Serializer):
    motive = serializers.CharField()
    solicity = SolicitySerializer()