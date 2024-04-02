import datetime
from rest_framework import serializers
from entity_app.domain.models.publication import Attachment, Publication, Tag, FilePublication
from entity_app.domain.models.type_formats import TypeFormats
from entity_app.domain.models.solicity import Solicity
from entity_app.domain.models.transparency_active import Numeral, TemplateFile, ColumnFile, TransparencyActive
from entity_app.domain.models.establishment import EstablishmentExtended


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

        read_only_fields = ('id', 'description')


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
    user_created = serializers.SerializerMethodField(
        method_name='get_user_created')
    email_created = serializers.CharField(
        source='user_created.email', read_only=True, required=False, allow_null=True)
    user_updated = serializers.CharField(
        source='user_updated.username', read_only=True, required=False, allow_null=True)
    user_deleted = serializers.CharField(
        source='user_deleted.username', read_only=True, required=False, allow_null=True)
    slug = serializers.SlugField(
        allow_blank=True, allow_unicode=True, allow_null=True)
    attachment = AttachmentSerializer(many=True)
    notes = serializers.CharField(allow_blank=True, allow_null=True)

    class Meta:
        """Meta class."""
        model: 'Publication'
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

    def send_errors(self, errors, status):
        e = ""
        for error in errors:
            e += error[0] + ", "

        return MessageTransactional(message=e, status=status, json=errors).data


class SolicityCreateSerializer(serializers.Serializer):
    """Solicity create serializer"""
    establishment_id = serializers.IntegerField()
    # title=serializers.CharField();
    description = serializers.CharField()
    first_name = serializers.CharField()
    last_name = serializers.CharField()
    email = serializers.CharField()
    identification = serializers.CharField()
    address = serializers.CharField()
    phone = serializers.CharField()
    type_reception = serializers.CharField()
    formatSolicity = serializers.CharField()
    expiry_date = serializers.DateTimeField()


class SolicityCreateResponseSerializer(serializers.Serializer):
    """Solicity Create Response serializer."""

    id_solicitud = serializers.IntegerField()
    text = serializers.CharField()
    files = serializers.ListField(child=serializers.IntegerField())
    attachment = serializers.ListField(child=serializers.IntegerField())
    category_id = serializers.IntegerField()


class SolicitySerializer(serializers.ModelSerializer):

    class Meta:

        model = Solicity
        fields = (
            'id',
            'text',
            'establishment',
            'is_active',
            'status',
            'expiry_date',
            'have_extension',
            'is_manual',
        )

        read_only_fields = ('id', 'is_active', 'status',
                            'have_extension', 'is_manual')


class CreateExtensionSerializer(serializers.Serializer):

    motive = serializers.CharField()
    solicity = SolicitySerializer()


class CreateInsistencySerializer(serializers.Serializer):
    motive = serializers.CharField()
    solicity = SolicitySerializer()


class CreateManualSolicitySerializer(serializers.Serializer):
    title = serializers.CharField()
    text = serializers.CharField()
    expiry_date = serializers.DateTimeField()
    establishment_id = serializers.IntegerField()


class SolicityResponseSerializer(serializers.Serializer):
    text = serializers.CharField()
    category_id = serializers.IntegerField()
    files = serializers.ListField(child=serializers.IntegerField())
    attachments = serializers.ListField(child=serializers.IntegerField())
    solicity_id = serializers.IntegerField()


class ColumnFileSerializer(serializers.ModelSerializer):
    """Column file serializer."""
    class Meta:
        """Meta class."""
        model = ColumnFile
        fields = (
            'id',
            'name',
            'code',
            'type',
            'format',
            'regex',

        )


class TemplateResponseSerializer(serializers.ModelSerializer):

    columns = serializers.SerializerMethodField(method_name='get_columns')

    class Meta:
        model = TemplateFile

        read_only_fields = ('id', 'is_active',
                            'vertical_template', 'max_inserts', 'columns')

        fields = '__all__'

    def get_columns(self, obj):
        columns = obj.columns.all()
        return ColumnFileSerializer(columns, many=True).data


class TemplateFileValidateSerializer(serializers.Serializer):
    template_id = serializers.IntegerField()
    file = serializers.FileField()


class PartialTemplateFileSerializer(serializers.ModelSerializer):

    class Meta:
        model = TemplateFile
        fields = [
            'id', 'name'
        ]


class NumeralResponseSerializer(serializers.ModelSerializer):
    """Numeral response serializer."""
    templates = PartialTemplateFileSerializer(many=True)
    published = serializers.SerializerMethodField(method_name='get_published')

    class Meta:
        """Meta class."""
        model = Numeral
        fields = '__all__'

    def get_published(self, obj):

        transparency = TransparencyActive.objects.filter(numeral=obj, published=True,
                                                         month=datetime.datetime.now().month, year=datetime.datetime.now().year).first()

        if transparency is not None:
            return True

        return False


class EstablishmentSerializer(serializers.ModelSerializer):
    """Establishment serializer."""
    class Meta:
        """Meta class."""
        model = EstablishmentExtended
        fields = '__all__'


class TransparencyCreateResponseSerializer(serializers.ModelSerializer):
    """Numeral response serializer."""
    files = FilePublicationSerializer(many=True)
    establishment = EstablishmentSerializer()

    class Meta:
        """Meta class."""
        model = TransparencyActive
        fields = '__all__'


class NumeralDetailSerializer(serializers.ModelSerializer):
    """Numeral detail serializer."""

    templates = serializers.SerializerMethodField(method_name='get_templates')

    class Meta:
        """Meta class."""
        model = Numeral
        fields = '__all__'

    def get_templates(self, obj):
        templates = obj.templates.all()

        return TemplateResponseSerializer(templates, many=True).data


class TransparencyActiveListSerializer(serializers.ModelSerializer):
    numeral = serializers.SerializerMethodField(method_name='get_numeral')
    files = FilePublicationSerializer(many=True)

    class Meta:
        model = TransparencyActive
        fields = '__all__'

    def get_numeral(self, obj):
        numeral = obj.numeral
        return {
            'id': numeral.id,
            'name': numeral.name,
            'description': numeral.description
        }


class TransparecyActiveCreate(serializers.Serializer):
    establishment_id = serializers.IntegerField()
    numeral_id = serializers.IntegerField()
    files = serializers.ListField(child=serializers.IntegerField())


class TransparencyColaboratyCreate(serializers.Serializer):
    establishment_id = serializers.IntegerField()
    numeral_id = serializers.IntegerField()
    files = serializers.ListField(child=serializers.IntegerField())


class TransparencyFocusCreate(serializers.Serializer):
    establishment_id = serializers.IntegerField()
    numeral_id = serializers.IntegerField()
    files = serializers.ListField(child=serializers.IntegerField())


class ListTransparencyFocus(serializers.Serializer):
    establishment = serializers.IntegerField()
    numeral = serializers.IntegerField()
    files = serializers.ListField(child=serializers.IntegerField())
    slug = serializers.BooleanField()
    month = serializers.IntegerField()
    year = serializers.IntegerField()
    status = serializers.CharField()
    published = serializers.BooleanField()
    published_at = serializers.DateTimeField()
    max_date_to_publish = serializers.DateTimeField()


class ListTransparencyColaborative(serializers.Serializer):
    establishment = serializers.IntegerField()
    numeral = serializers.IntegerField()
    files = serializers.ListField(child=serializers.IntegerField())
    slug = serializers.BooleanField()
    month = serializers.IntegerField()
    year = serializers.IntegerField()
    status = serializers.CharField()
    published = serializers.BooleanField()
    published_at = serializers.DateTimeField()
    max_date_to_publish = serializers.DateTimeField()
