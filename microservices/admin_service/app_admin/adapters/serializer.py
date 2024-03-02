from django.db.models import ImageField
from rest_framework.fields import ListField
from rest_framework.serializers import ModelSerializer, Serializer, CharField, IntegerField, JSONField, PrimaryKeyRelatedField
from app_admin.domain.models import Configuration, Establishment, FormFields, FrequentlyAskedQuestions, TutorialVideo, NormativeDocument


class EstablishmentListSerializer(ModelSerializer):
    
    class Meta:
        model = Establishment
        fields = '__all__'
        
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['logo'] = instance.logo.url
        return representation


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
    extra_numerals = CharField(allow_blank=True)


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

        content_type = instance.content_type
        if content_type is None:
            return representation
        object_id = instance.object_id
        related_model = content_type.model_class()
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