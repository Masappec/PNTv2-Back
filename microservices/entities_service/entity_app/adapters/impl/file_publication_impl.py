from entity_app.ports.repositories.file_publication_repository import FilePublicationRepository
from entity_app.domain.models.publication import FilePublication
from entity_app.domain.models.establishment import EstablishmentExtended, UserEstablishmentExtended
from django.apps import apps
from django.contrib.auth.models import User
from entity_app.models import TransparencyActive, TransparencyColab, TransparencyFocal


class FilePublicationImpl(FilePublicationRepository):

    def save(self, name, description, file):
        return FilePublication.objects.create(name=name, description=description, url_download=file)

    def get(self, file_publication_id):
        return FilePublication.objects.get(id=file_publication_id)

    def update(self, file_publication_id, name, description, file):
        file_publication = FilePublication.objects.get(id=file_publication_id)
        file_publication.name = name
        file_publication.description = description
        file_publication.url_download = file
        file_publication.save()
        return file_publication

    def get_all(self):
        return FilePublication.objects.all()

    def delete(self, file_publication_id):
        return FilePublication.objects.get(id=file_publication_id).delete()

    def get_by_user_establishment(self, user_id, type, numeral_id):

        user = User.objects.get(id=user_id)

        if user.is_superuser:
            return FilePublication.objects.all()

        user_establishment = UserEstablishmentExtended.objects.filter(
            user_id=user_id, is_active=True).last()
        if type == 'TA':
            ta = TransparencyActive.objects.filter(
                establishment_id=user_establishment.establishment_id, numeral_id=numeral_id)
            return FilePublication.objects.filter(transparency_active__in=ta).distinct('id')

        if type == 'TC':
            tc = TransparencyColab.objects.filter(
                establishment_id=user_establishment.establishment_id, numeral_id=numeral_id)

            return FilePublication.objects.filter(transparency_colab__in=tc).distinct('id')
        if type == 'TF':
            tf = TransparencyFocal.objects.filter(
                establishment_id=user_establishment.establishment_id, numeral_id=numeral_id)

            return FilePublication.objects.filter(transparency_focal__in=tf).distinct('id')

    def get_files_from_transparency_active(self, user_id):
        user = User.objects.get(id=user_id)

        if user.is_superuser:
            return FilePublication.objects.all()

        user_establishment = UserEstablishmentExtended.objects.filter(
            user_id=user_id).first()
        if not user_establishment:
            raise Exception('El usuario no tiene un establecimiento asignado')
        publications = TransparencyActive.objects.filter(
            establishment_id=user_establishment.establishment_id)

        files = FilePublication.objects.filter(
            transparency_active__in=publications).distinct('id')
        return files

    def get_files_from_transparency_collaborative(self, establishment_id):
        pass

    def get_files_from_transparency_focus(self, establishment_id):
        pass
