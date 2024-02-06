from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from entity_app.domain.models.solicity import Solicity

def create_custom_permissions():
    content_type = ContentType.objects.get_for_model(Solicity)

    Permission.objects.get_or_create(
        codename='add_manual_solicity',
        name='Puede crear solicitud manual',
        content_type=content_type,
    )
