from entity_app.ports.repositories.transparency_colaborative_repository import TransparencyColaborativeRepository
from entity_app.domain.models.transparecy_colab import TransparencyColab
from entity_app.domain.models.publication import FilePublication

from entity_app.domain.models.establishment import UserEstablishmentExtended


class TransparencyColaborativeImpl(TransparencyColaborativeRepository):

    def createTransparencyColaborative(self, establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha, status="ingress"):
        file_instances = FilePublication.objects.filter(id__in=files)

        response = TransparencyColab.objects.create(establishment_id=establishment_id,
                                                    numeral_id=numeral_id,
                                                    month=month,
                                                    year=year,
                                                    status=status,
                                                    published=True,
                                                    max_date_to_publish=max_fecha,
                                                    published_at=fecha_actual if status == "ingress" else None)

        response.files.set(file_instances)

        return response

    def getTransparencyColaborativeUser(self, user_id):
        user_es = UserEstablishmentExtended.objects.filter(
            user_id=user_id).last()

        response = TransparencyColab.objects.filter(
            establishment_id=user_es.establishment.id)

        return response

    def deleteTransparencyColaborativeUser(self, pk, user_id):
        user_es = UserEstablishmentExtended.objects.get(user_id=user_id)

        response = TransparencyColab.objects.get(
            establishment_id=user_es.establishment.id, id=pk).delete()

        return response

    def update_transparency_colaborative(self, pk, user_id, newfiles):

        user_es = UserEstablishmentExtended.objects.get(user_id=user_id)

        response = TransparencyColab.objects.get(
            establishment_id=user_es.establishment.id, id=pk)

        file_instances = FilePublication.objects.filter(id__in=newfiles)

        response.files.set(file_instances)

        return response
