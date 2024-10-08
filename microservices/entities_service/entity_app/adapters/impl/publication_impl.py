from entity_app.ports.repositories.publication_repository import PublicationRepository
from entity_app.domain.models import Publication, Tag, FilePublication
from entity_app.domain.models.establishment import UserEstablishmentExtended
from django.contrib.auth.models import User
from django.db.models import Q

from entity_app.domain.models.publication import Attachment, TypePublication


class PublicationImpl(PublicationRepository):

    def inactivate_activate_publication(self, publication_id: int, user_id: int):

        user = User.objects.get(id=user_id)
        if user.is_superuser:
            return Publication.objects.filter(id=publication_id).update(is_active=False)

        user_es = UserEstablishmentExtended.objects.get(user_id=user_id)
        pub = Publication.objects.get(
            id=publication_id, establishment_id=user_es.establishment.id)
        pub.is_active = not pub.is_active
        pub.save()
        return pub

    def get_publication(self, publication_id: int):

        publication = Publication.objects.get(id=publication_id)

        return publication

    def get_publications_transparency_active(self):

        publications = Publication.objects.filter(is_active=True).filter(
            Q(type_publication__code='TA') | Q(type_publication__code='TC'))

        return publications

    def get_publications(self):
        publications = Publication.objects.all()

    def get_publications_by_user_id(self, user_id: int):

        user = User.objects.get(id=user_id)
        if user.is_superuser:
            publications = Publication.objects.all()
            return publications

        user_es = UserEstablishmentExtended.objects.get(user_id=user_id)

        publications = Publication.objects.filter(
            establishment_id=user_es.establishment.id)

        return publications

    def get_publication_detail_admin(self, publication_id: int, user_id: int):

        user = User.objects.get(id=user_id)
        if user.is_superuser:
            publication = Publication.objects.get(id=publication_id)
            return publication

        user_es = UserEstablishmentExtended.objects.get(user_id=user_id)
        publication = Publication.objects.get(
            id=publication_id, establishment_id=user_es.establishment.id)

        return publication

    def get_publication_by_slug(self, slug: str):

        publication = Publication.objects.filter(slug=slug, is_active=True).filter(
            Q(type_publication__code='TA') | Q(type_publication__code='TC')).first()

        return publication

    def create_publication(self, publicacion: dict):

        tags_instancias = Tag.objects.filter(
            id__in=publicacion['group_dataset'])
        file_instancias = FilePublication.objects.filter(
            id__in=publicacion['file_publication'])
        attachment_instancias = Attachment.objects.filter(
            id__in=publicacion['attachment'])

        type_publication = TypePublication.objects.get(
            code=publicacion['type_publication'])

        nueva_publicacion = Publication.objects.create(
            name=publicacion['name'],
            description=publicacion['description'],
            type_publication=type_publication,
            notes=publicacion['notes'],
            establishment_id=publicacion['establishment_id'],
            user_created_id=publicacion['user_created_id'],
        )
        nueva_publicacion.tag.set(tags_instancias)
        nueva_publicacion.file_publication.set(file_instancias)
        nueva_publicacion.attachment.set(attachment_instancias)

        nueva_publicacion.save()

    def update_publication(self, publication_id: int, publicacion: dict):

        tags_instancias = None
        file_instancias = None
        attachment_instancias = None
        print("publicacion", publicacion)
        if 'group_dataset' in publicacion:
            if publicacion['group_dataset']:
                tags_instancias = Tag.objects.filter(
                    id__in=publicacion['group_dataset'])

        if 'file_publication' in publicacion:
            if publicacion['file_publication']:
                file_instancias = FilePublication.objects.filter(
                    id__in=publicacion['file_publication'])

        if 'attachment' in publicacion:
            if publicacion['attachment']:
                attachment_instancias = Attachment.objects.filter(
                    id__in=publicacion['attachment'])

        publicacion_obj = Publication.objects.filter(id=publication_id).first()
        publicacion_obj.name = publicacion['name']
        publicacion_obj.description = publicacion['description']
        if tags_instancias:
            print("tags_instancias ", tags_instancias)
            publicacion_obj.tag.set(tags_instancias)

        if file_instancias:
            print("file_instancias", file_instancias)
            publicacion_obj.file_publication.set(file_instancias)

        if attachment_instancias:
            print("attachment_instancias", attachment_instancias)
            publicacion_obj.attachment.set(attachment_instancias)

        publicacion_obj.user_updated_id = publicacion['user_updated_id']

        publicacion_obj.save()

        return publicacion_obj
