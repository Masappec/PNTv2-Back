from django.db.models import ImageField
from rest_framework.serializers import ModelSerializer, Serializer, CharField, IntegerField, JSONField, ListField, PrimaryKeyRelatedField
from app_admin.domain.models import Establishment, FormFields


class EstablishmentListSerializer(ModelSerializer):
    
    
    class Meta:
        model = Establishment
        fields = '__all__'


class EstablishmentCreateSerializer(Serializer):
    name = CharField(max_length=255)
    code = CharField(max_length=255)
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
        


class MessageTransactional(Serializer):
    message = CharField(max_length=255)
    status = IntegerField()
    json = JSONField()
    

class FormFieldsListSerializer(ModelSerializer):
    
    
    class Meta:
        model = FormFields
        fields = '__all__'