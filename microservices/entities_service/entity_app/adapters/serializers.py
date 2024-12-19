import datetime
from rest_framework import serializers
from entity_app.domain.models.publication import Attachment, Publication, Tag, FilePublication
from entity_app.domain.models.type_formats import TypeFormats
from entity_app.domain.models.solicity import Solicity, SolicityResponse, Status, TimeLineSolicity, Extension, Insistency
from entity_app.domain.models.transparency_active import EstablishmentNumeral, Numeral, TemplateFile, ColumnFile, TransparencyActive
from entity_app.domain.models.establishment import EstablishmentExtended
from entity_app.domain.models.transparecy_foc import TransparencyFocal
from entity_app.domain.models.transparecy_colab import TransparencyColab
from entity_app.domain.models.anual_report import AnualReport
from django.db.models import Q


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
    url_download = serializers.ReadOnlyField(source='relative_url')

    class Meta:
        model = FilePublication
        fields = (
            'id',
            'name',
            'description',
            'url_download',
            'created_at'
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


class SolicityCreateDraftSerializer(serializers.ModelSerializer):
    """Solicity create serializer"""

    class Meta:
        model = Solicity
        exclude = ('id', 'ip', 'is_active', 'status',
                   'date',
                   'address',
                   'have_extension', 'is_manual', 'expiry_date', 'user_created', 'user_updated', 'user_deleted',
                   'created_at', 'updated_at', 'deleted_at', 'deleted')


class SolicityManualSerializer(serializers.ModelSerializer):
    """Solicity create serializer"""

    class Meta:
        model = Solicity
        exclude = ('id', 'ip', 'is_active', 'status',
                   'address',
                   'have_extension', 'is_manual', 'expiry_date', 'user_created', 'user_updated', 'user_deleted',
                   'created_at', 'updated_at', 'deleted_at', 'deleted')


class SolicityCreateWithDraftSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField()
    is_send = serializers.BooleanField()

    class Meta:
        model = Solicity
        exclude = ('ip', 'is_active', 'status',
                   'date',
                   'address',
                   'have_extension', 'is_manual', 'expiry_date', 'user_created', 'user_updated', 'user_deleted',
                   'created_at', 'updated_at', 'deleted_at', 'deleted')


class SolicityCreateResponseSerializer(serializers.Serializer):
    """Solicity Create Response serializer."""

    id_solicitud = serializers.IntegerField()
    text = serializers.CharField()
    files = serializers.ListField(child=serializers.IntegerField())
    attachment = serializers.ListField(child=serializers.IntegerField())


class SolicitySerializer(serializers.ModelSerializer):
    estblishment_name = serializers.CharField(
        source='establishment.name', read_only=True)
    time_line = serializers.SerializerMethodField(method_name='get_time_line')
    responses = serializers.SerializerMethodField(method_name='get_responses')
    comments = serializers.SerializerMethodField(method_name='get_comments')
    insistency = serializers.SerializerMethodField(
        method_name='get_insistency')

    class Meta:

        model = Solicity
        fields = '__all__'

        read_only_fields = ('id', 'is_active', 'status',
                            'have_extension', 'is_manual')

    def get_time_line(self, obj):
        time_line = TimeLineSolicity.objects.filter(solicity=obj)
        list_ = []
        for i in time_line:
            list_.append({
                'status': i.status,
                'created_at': i.created_at
            })
        return list_

    def get_responses(self, obj):
        responses = SolicityResponse.objects.filter(solicity=obj)
        data = SolicityResponseSerializer(responses, many=True).data
        return data

    def get_comments(self, obj):
        comments = Extension.objects.filter(solicity=obj)

        return ExtensionSerializer(comments, many=True).data

    def get_insistency(self, obj):

        insistency = Insistency.objects.filter(solicity=obj)

        return InsistencySerializer(insistency, many=True).data


class ExtensionSerializer(serializers.ModelSerializer):
    files = FilePublicationSerializer(many=True)
    
    class Meta:
        model = Extension
        fields = '__all__'


class InsistencySerializer(serializers.ModelSerializer):

    class Meta:
        model = Insistency
        fields = '__all__'


class SolicityResponseSerializer(serializers.ModelSerializer):
    """Solicity response serializer."""
    files = FilePublicationSerializer(many=True)
    attachments = AttachmentSerializer(many=True)
    user = serializers.SerializerMethodField(method_name='get_user')

    class Meta:
        """Meta class."""
        model = SolicityResponse
        fields = '__all__'

        read_only_fields = ('id', 'is_active', 'solicity', 'user')

    def get_user(self, obj):
        return {
            'id': obj.user.id,
            'first_name': obj.user.first_name,
            'last_name': obj.user.last_name,
            'email': obj.user.email

        }


class CreateExtensionSerializer(serializers.Serializer):

    motive = serializers.CharField()
    solicity_id = serializers.IntegerField()


class CreateInsistencySerializer(serializers.Serializer):
    motive = serializers.CharField()
    solicity = SolicitySerializer()


class CreateManualSolicitySerializer(serializers.Serializer):
    title = serializers.CharField()
    text = serializers.CharField()
    expiry_date = serializers.DateTimeField()
    establishment_id = serializers.IntegerField()


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
            'value'

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
    publication = serializers.SerializerMethodField(
        method_name='get_publication')

    class Meta:
        """Meta class."""
        model = Numeral
        fields = '__all__'

    def get_published(self, obj):

        transparency = TransparencyActive.objects.filter(numeral=obj, published=True,
                                                         establishment_id=self.context['establishment_id'],
                                                         month=self.context['month'], year=self.context['year'])

        if transparency.count() > 0:
            return True

        return False

    def get_publication(self, obj):

        transparency = TransparencyActive.objects.filter(numeral=obj,
                                                         establishment_id=self.context['establishment_id'],
                                                         month=self.context['month'], year=self.context['year']).first()

        if transparency:
            return TransparencyActiveListSerializer(transparency).data

        return None


class EstablishmentSerializer(serializers.ModelSerializer):
    """Establishment serializer."""
    class Meta:
        """Meta class."""
        model = EstablishmentExtended
        fields = '__all__'


class EstablishmentScoreSerializer(serializers.Serializer):
    establishment = EstablishmentSerializer()
    score_saip = serializers.FloatField()
    total_recibidas = serializers.IntegerField()
    total_atendidas = serializers.IntegerField()
    total_prorroga = serializers.IntegerField()
    total_insistencia = serializers.IntegerField()
    total_no_respuesta = serializers.IntegerField()


class EstablishmentcomplianceSerializer(serializers.ModelSerializer):
    total_published_ta = serializers.IntegerField(read_only=True)
    total_numeral_ta = serializers.IntegerField(read_only=True)
    total_solicities_res = serializers.IntegerField(read_only=True)
    total_solicities_rec = serializers.IntegerField(read_only=True)
    total_tf = serializers.IntegerField(read_only=True)
    total_tc = serializers.IntegerField(read_only=True)

    class Meta:
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


class TransparencyApproveSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    establishment_id = serializers.IntegerField()
    type = serializers.CharField()


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
    establishment = EstablishmentSerializer()

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
    month = serializers.IntegerField()
    year = serializers.IntegerField()


class TransparencyColaboratyCreate(serializers.Serializer):
    establishment_id = serializers.IntegerField()
    files = serializers.ListField(child=serializers.IntegerField())


class TransparencyFocusCreate(serializers.Serializer):
    establishment_id = serializers.IntegerField()
    files = serializers.ListField(child=serializers.IntegerField())


class TransparencyFocusSerializer(serializers.ModelSerializer):

    class Meta:
        model = TransparencyFocal
        fields = '__all__'


class ListTransparencyFocus(serializers.ModelSerializer):
    numeral = serializers.SerializerMethodField(method_name='get_numeral')
    files = FilePublicationSerializer(many=True)
    establishment = EstablishmentSerializer()

    class Meta:
        model = TransparencyFocal
        fields = '__all__'

    def get_numeral(self, obj):
        numeral = obj.numeral
        return {
            'id': numeral.id,
            'name': numeral.name,
            'description': numeral.description
        }


class ListTransparencyColaborative(serializers.ModelSerializer):
    numeral = serializers.SerializerMethodField(method_name='get_numeral')
    files = FilePublicationSerializer(many=True)
    establishment = EstablishmentSerializer()

    class Meta:
        model = TransparencyColab
        fields = '__all__'

    def get_numeral(self, obj):
        numeral = obj.numeral
        return {
            'id': numeral.id,
            'name': numeral.name,
            'description': numeral.description
        }


class AnualReportCreateSerializer(serializers.ModelSerializer):

    class Meta:
        model = AnualReport
        exclude = ('id', 'created_at', 'updated_at', 'deleted_at', 'deleted')
        
class AnualReportSerializer(serializers.ModelSerializer):

    class Meta:
        model = AnualReport
        fields = '__all__'