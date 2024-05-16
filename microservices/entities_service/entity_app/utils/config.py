from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from entity_app.domain.models.solicity import Solicity


def create_custom_permissions():
    # content_type = ContentType.objects.get_for_model(Solicity)
    '''Permission.objects.get_or_create(
        codename='add_manual_solicity',
        name='Puede crear solicitud manual',
        content_type=content_type,
    )


    Permission.objects.get_or_create(
        codename='view_transparency_active_all',
        name='Puede Ver todas las cargas de numerales',
        content_type=content_type,
    )

    Permission.objects.get_or_create(
        codename='view_transparency_active',
        name='Puede Ver cargas de numerales que le pertenecen',
        content_type=content_type,
    )'''

    permission = Permission.objects.get_or_create(
        codename='add_user_establishment',
        name='Puede agregar usuarios de entidad',
        content_type=ContentType.objects.filter(model='user').first()
    )

    permission = Permission.objects.get_or_create(
        codename='delete_user_establishment',
        name='Puede eliminar usuarios de entidad',
        content_type=ContentType.objects.filter(model='user').first()
    )

    permission = Permission.objects.get_or_create(
        codename='update_user_establishment',
        name='Puede actualizar usuarios de entidad',
        content_type=ContentType.objects.filter(model='user').first()
    )

    permission = Permission.objects.get_or_create(
        codename='view_user_establishment',
        name='Puede ver usuarios de entidad',
        content_type=ContentType.objects.filter(model='user').first()
    )

    permission = Permission.objects.get_or_create(
        codename='view_establishment_internal',
        name='Puede ver informacion de institución',
        content_type=ContentType.objects.get(model='establishment')
    )

    permission = Permission.objects.get_or_create(
        codename='add_establishment_internal',
        name='Puede agregar informacion de institución',
        content_type=ContentType.objects.get(model='establishment')
    )

    permission = Permission.objects.get_or_create(
        codename='delete_establishment_internal',
        name='Puede eliminar informacion de institución',
        content_type=ContentType.objects.get(model='establishment')
    )

    permission = Permission.objects.get_or_create(
        codename='update_establishment_internal',
        name='Puede actualizar informacion de institución',
        content_type=ContentType.objects.get(model='establishment')
    )

    permission = Permission.objects.get_or_create(
        codename='add_manual_solicity',
        name='Puede agregar solicitudes manuales',
        content_type=ContentType.objects.get(model='solicityresponse')
    )
