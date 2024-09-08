from django.db.models import ImageField
from django.contrib.auth.models import Group
from rest_framework.fields import ListField
from rest_framework.serializers import ModelSerializer, Serializer, CharField, IntegerField, JSONField, PrimaryKeyRelatedField
from app_admin.domain.models import Configuration, Establishment, \
    FormFields, FrequentlyAskedQuestions, TutorialVideo, NormativeDocument, TypeInstitution, \
    FunctionOrganization, TypeOrganization
from django.contrib.auth.models import User
import json


class EstablishmentListSerializer(ModelSerializer):
    address = CharField(max_length=255, allow_blank=True, allow_null=True)
    class Meta:
        model = Establishment
        fields = '__all__'

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['logo'] = instance.logo.url if instance.logo else None
        representation['type_institution'] = instance.type_institution.name if instance.type_institution else None
        representation['type_organization'] = instance.type_organization.name if instance.type_organization else None
        representation['function_organization'] = instance.function_organization.name if instance.function_organization else None
        return representation
    
    


class EstablishmentCreateSerializer(Serializer):
    name = CharField(max_length=255)
    alias = CharField(max_length=255)
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
    extra_numerals = CharField(allow_blank=True)
    type_institution = PrimaryKeyRelatedField(
        queryset=TypeInstitution.objects.all(), allow_null=True)
    identification = CharField(max_length=255)
    type_organization = PrimaryKeyRelatedField(
        queryset=TypeOrganization.objects.all(), allow_null=True)
    function_organization = PrimaryKeyRelatedField(
        queryset=FunctionOrganization.objects.all(), allow_null=True)
    address = CharField(max_length=255, allow_blank=True, allow_null=True)


class EstablishmentCreateResponseSerializer(Serializer):
    id = IntegerField()
    alias = CharField(max_length=255, allow_null=True, allow_blank=True)

    name = CharField(max_length=255)
    abbreviation = CharField(max_length=255)
    logo = CharField(max_length=255, allow_null=True)
    highest_authority = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    first_name_authority = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    last_name_authority = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    job_authority = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    email_authority = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    highest_committe = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    first_name_committe = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    last_name_committe = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    job_committe = CharField(max_length=255, allow_null=True, allow_blank=True)
    email_committe = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    email_accesstoinformation = CharField(
        max_length=255, allow_null=True, allow_blank=True)
    address = CharField(max_length=255, allow_blank=True, allow_null=True)
    type_institution = IntegerField(allow_null=True)
    type_organization = IntegerField(allow_null=True)
    function_organization = IntegerField(allow_null=True)
    identification = CharField(
        max_length=255, allow_null=True, allow_blank=True)


class MessageTransactional(Serializer):
    message = CharField(max_length=1000)
    status = IntegerField()
    json = JSONField()


class FrequentlyAskeeQuestionsSerializer(Serializer):
    question = CharField(max_length=255)
    answer = CharField(max_length=255)
    user = IntegerField()


class FrequentlyAskedQuestionsSerializerBody(Serializer):
    faq = ListField(child=JSONField())


class FormFieldsListSerializer(ModelSerializer):

    class Meta:
        model = FormFields
        fields = '__all__'

    def to_representation(self, instance):
        representation = super().to_representation(instance)

        options = instance.options
        if options is not None:
            try:

                options = json.loads(options)
                representation['options'] = options

            except Exception as e:
                pass
        content_type = instance.content_type
        if content_type is None:
            return representation
        object_id = instance.object_id
        print(content_type, object_id)
        related_model = content_type.model_class()
        if related_model:
            related_instances = related_model.objects.all().values('id', 'name')
            option_values = [
                related_instance for related_instance in related_instances]

            representation['options'] = option_values

        return representation


class ConfigurationResponseSerializer(ModelSerializer):

    class Meta:
        model = Configuration
        fields = ['id', 'name', 'value']


class ConfigurationSerializer(ModelSerializer):

    class Meta:
        model = Configuration
        fields = ['name', 'value']


class FAQSerializer(Serializer):
    question = CharField(max_length=255)
    answer = CharField(max_length=1000)


class TutorialSerializer(Serializer):
    title = CharField(max_length=255)
    description = CharField(max_length=1000)
    url = CharField(max_length=255)


class NormativeSerializer(Serializer):
    title = CharField(max_length=255)
    description = CharField(max_length=1000)
    url = CharField(max_length=255)


class PedagogyAreaSerializerCreate(Serializer):
    faq = FAQSerializer(many=True)
    tutorial = TutorialSerializer(many=True)
    normative = NormativeSerializer(many=True)


class FAQSerializerResponse(ModelSerializer):

    class Meta:
        model = FrequentlyAskedQuestions
        fields = '__all__'


class TutorialSerializerResponse(ModelSerializer):

    class Meta:
        model = TutorialVideo
        fields = '__all__'


class NormativeSerializerResponse(ModelSerializer):

    class Meta:
        model = NormativeDocument
        fields = '__all__'


class PedagogyAreaSerializerResponse(Serializer):

    faq = FAQSerializerResponse(many=True)
    tutorial = TutorialSerializerResponse(many=True)
    normative = NormativeSerializerResponse(many=True)


class GroupSerializer(ModelSerializer):

    class Meta:
        model = Group
        fields = ('id', 'name')


class UserListSerializer(ModelSerializer):
    group = ListField(child=GroupSerializer(), allow_null=True)

    class Meta:
        model = User
        exclude = ['password']
