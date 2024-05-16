from app.ports.repositories.permission_repository import PermissionRepository
from app.domain.models import Permission, User


class PermissionRepositoryImpl(PermissionRepository):

    def get_permission(self, permission_id: int):
        return Permission.objects.get(pk=permission_id)

    def get_permission_by_name(self, name: str):
        return Permission.objects.get(name=name)

    def get_permission_by_code(self, code: str):
        return Permission.objects.get(code=code)

    def create_permission(self, permission: dict):

        return Permission.objects.create(**permission)

    def update_permission(self, permission_id: int, permission: dict):
        return Permission.objects.filter(pk=permission_id).update(**permission)

    def get_permissions(self):
        return Permission.objects.all().exclude(content_type__model__in=[
            'contenttype', 'logentry', 'permission', 'session', 'basemodel', 'accesstoinformation',
            'resetpasswordtoken', 'userestablishmentextended', 'lawenforcement', 'accesstoinformation',
            'formfields', 'tutorialvideo', 'normativedocument', 'frequentlyaskedquestions', 'userestablishment',
            'email', 'typepublication', 'filepublication', 'establishmentextended', 'typeformats', 'activitylog',
            'userestablishmentextended', 'attachment', 'columnfile', 'templatefile', 'numeral', 'establishmentnumeral', 'role',
            'periodictasks', 'insistency', 'publication', 'solarschedule', 'periodictask', 'intervalschedule', 'crontabschedule',
            'clockedschedule', 'typeorganization', 'functionorganization', 'Datos Personales', 'category', 'extension',
            'tag', 'user',
            'typeinstitution', 'timelinesolicity'
        ])

    def get_permissions_by_role(self, role_id: int):
        return Permission.objects.filter(group__id=role_id).exclude(
            content_type__model__in=[
                'contenttype', 'logentry', 'permission', 'session', 'basemodel', 'accesstoinformation',
                'resetpasswordtoken', 'userestablishmentextended', 'lawenforcement', 'accesstoinformation',
                'formfields', 'tutorialvideo', 'normativedocument', 'frequentlyaskedquestions', 'userestablishment',
                'email', 'typepublication', 'filepublication', 'establishmentextended', 'typeformats', 'activitylog',
                'userestablishmentextended', 'attachment', 'columnfile', 'templatefile', 'numeral', 'establishmentnumeral', 'role',
                'periodictasks', 'insistency', 'publication', 'solarschedule', 'periodictask', 'intervalschedule', 'crontabschedule',
                'clockedschedule', 'typeorganization', 'functionorganization', 'Datos Personales', 'category', 'extension',
                'tag', 'user',
                'typeinstitution', 'timelinesolicity'
            ]

        )

    def get_permissions_by_user(self, user_id: int):
        user = User.objects.get(pk=user_id)

        group = user.groups.all()

        if user.is_superuser:
            return Permission.objects.all().exclude(content_type__model__in=[
                'contenttype', 'logentry', 'permission', 'session', 'basemodel', 'accesstoinformation',
                'resetpasswordtoken', 'userestablishmentextended', 'lawenforcement', 'accesstoinformation',
                'formfields', 'tutorialvideo', 'normativedocument', 'frequentlyaskedquestions', 'userestablishment',
                'email', 'typepublication', 'filepublication', 'establishmentextended', 'typeformats', 'activitylog',
                'userestablishmentextended', 'attachment', 'columnfile', 'templatefile', 'numeral', 'establishmentnumeral',
                'role'

            ]).values('codename')

        return Permission.objects.filter(group__in=group).exclude(content_type__model__in=[
            'contenttype', 'logentry', 'permission', 'session', 'basemodel', 'accesstoinformation',
            'resetpasswordtoken', 'userestablishmentextended', 'lawenforcement', 'accesstoinformation',
            'formfields', 'tutorialvideo', 'normativedocument', 'frequentlyaskedquestions', 'userestablishment',
            'email', 'typepublication', 'filepublication', 'establishmentextended', 'typeformats', 'activitylog',
            'userestablishmentextended', 'attachment', 'columnfile', 'templatefile', 'numeral', 'establishmentnumeral',
            'role'

        ]).values('codename')
