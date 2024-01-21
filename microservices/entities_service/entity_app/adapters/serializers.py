from rest_framework import serializers

from entity_app.domain.models.publication import Publication,Tag, FilePublication
from entity_app.domain.models.type_formats import TypeFormats

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


class FilePublicationSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = FilePublication
        fields = (
            'id',
            'name',
            'description',
            'url_download',
        )
        
class TypeFormatsSerializer(serializers.ModelSerializer):
        
        class Meta:
            model = TypeFormats
            fields = (
                'id',
                'name',
                'description',
            )
class PublicationPublicSerializer(serializers.Serializer):
    """Publication serializer."""
    id = serializers.IntegerField()
    name = serializers.CharField()
    description = serializers.CharField()
    is_active = serializers.BooleanField()
    establishment = serializers.IntegerField(source='establishment.id')
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
    class Meta:
        """Meta class."""
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
