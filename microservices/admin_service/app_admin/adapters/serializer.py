from django.db.models import ImageField
from rest_framework.serializers import ModelSerializer, Serializer, CharField, IntegerField, JSONField, PrimaryKeyRelatedField
from app_admin.domain.models import Establishment, FormFields


class EstablishmentListSerializer(ModelSerializer):
    
    
    class Meta:
        model = Establishment
        fields = '__all__'


class EstablishmentCreateSerializer(Serializer):
    name = CharField(max_length=255)
    abbreviation = CharField(max_length=255)
    logo = ImageField(upload_to='establishment')
    highest_authority = CharField(max_length=255)
    first_name_authority = CharField(max_length=255)
    last_name_authority = CharField(max_length=255)
    job_authority = CharField(max_length=255)
    email_authority = CharField(max_length=255)
    highest_committe = CharField(max_length=255)
    first_name_committe = CharField(max_length=255)
    last_name_committe = CharField(max_length=255)
    job_committe = CharField(max_length=255)
    email_committe = CharField(max_length=255)
    email_accesstoinformation = CharField(max_length=255)
        

class EstablishmentCreateResponseSerializer(Serializer):
    id = IntegerField()
    name = CharField(max_length=255)
    abbreviation = CharField(max_length=255)
    logo = CharField(max_length=255)
    highest_authority = CharField(max_length=255)
    first_name_authority = CharField(max_length=255)
    last_name_authority = CharField(max_length=255)
    job_authority = CharField(max_length=255)
    email_authority = CharField(max_length=255)
    highest_committe = CharField(max_length=255)
    first_name_committe = CharField(max_length=255)
    last_name_committe = CharField(max_length=255)
    job_committe = CharField(max_length=255)
    email_committe = CharField(max_length=255)
    email_accesstoinformation = CharField(max_length=255)

class MessageTransactional(Serializer):
    message = CharField(max_length=255)
    status = IntegerField()
    json = JSONField()
    

class FormFieldsListSerializer(ModelSerializer):
    
    
    class Meta:
        model = FormFields
        fields = '__all__'
        
        
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        
        content_type = instance.content_type
        if content_type is None:
            return representation
        object_id = instance.object_id
        related_model = content_type.model_class()
        related_instances = related_model.objects.all().values('id', 'name')
        option_values = [related_instance for related_instance in related_instances]

        representation['options'] = option_values

        return representation