from django.contrib.contenttypes.models import ContentType
from django.contrib.auth.models import Permission
from django.contrib.auth.models import Group


def create_custom_permissions():
    content_type = ContentType.objects.get_for_model(Group)

    permission = Permission.objects.get_or_create(
        codename='add_user_ciudadano',
        name='Puede crear usuario ciudadano',
        content_type=content_type,
    )
    permission = Permission.objects.get_or_create(
        codename='add_user_carga_pnt',
        name='Puede crear usuario Carga PNT',
        content_type=content_type,
    )

    permission = Permission.objects.get_or_create(
        codename='add_user_supervisora_pnt',
        name='Puede crear usuario Supervisora PNT',
        content_type=content_type,
    )

    permission = Permission.objects.get_or_create(
        codename='add_user_monitoreo_dpe',
        name='Puede crear usuario Monitoreo DPE',
        content_type=content_type,
    )

    permission = Permission.objects.get_or_create(
        codename='add_user_monitoreo_pnt_dpe',
        name='Puede crear usuario Supervisora PNT DPE',
        content_type=content_type,
    )

    permission = Permission.objects.get_or_create(
        codename='view_user_establishment',
        name='Puede ver usuarios de Entidad',
        content_type=content_type,
    )
