from rest_framework import serializers


class PublicationPublicSerializer(serializers.Serializer):
    """Publication serializer."""
    id = serializers.IntegerField()
    name = serializers.CharField()
    description = serializers.CharField()
    is_active = serializers.BooleanField()
    establishment = serializers.IntegerField()
    type_publication = serializers.IntegerField()
    tag = serializers.ListField()
    type_format = serializers.ListField()
    file_publication = serializers.ListField()
    created_at = serializers.DateTimeField()
    updated_at = serializers.DateTimeField()
    deleted_at = serializers.DateTimeField()
    created_by = serializers.IntegerField()
    updated_by = serializers.IntegerField()
    deleted_by = serializers.IntegerField()
    class Meta:
        """Meta class."""
        fields = (
            'id',
            'name',
            'description',
            'is_active',
            'establishment',
            'type_publication',
            'tag',
            'type_format',
            'file_publication',
            'created_at',
            'updated_at',
            'deleted_at',
            'created_by',
            'updated_by',
            'deleted_by',
        )
        read_only_fields = (
            'id',
            'created_at',
            'updated_at',
            'deleted_at',
            'created_by',
            'updated_by',
            'deleted_by',
        )