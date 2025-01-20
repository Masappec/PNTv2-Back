from datetime import datetime
from entity_app.ports.repositories.transparency_colaborative_repository import TransparencyColaborativeRepository
from entity_app.domain.models.transparecy_colab import TransparencyColab
from entity_app.domain.models.publication import FilePublication

from entity_app.domain.models.establishment import UserEstablishmentExtended
from entity_app.domain.models.transparency_active import StatusNumeral


class TransparencyColaborativeImpl(TransparencyColaborativeRepository):

    def createTransparencyColaborative(self, establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha, status="ingress"):
        file_instances = FilePublication.objects.filter(id__in=files)

        response = TransparencyColab.objects.create(establishment_id=establishment_id,
                                                    numeral_id=numeral_id,
                                                    month=month,
                                                    year=year,
                                                    status=StatusNumeral.INGRESS,
                                                    published=False,
                                                    max_date_to_publish=max_fecha,
                                                    published_at=None)

        response.files.set(file_instances)

        return response

    def getTransparencyColaborativeUser(self, user_id):
        user_es = UserEstablishmentExtended.objects.filter(
            user_id=user_id).last()

        response = TransparencyColab.objects.filter(
            establishment_id=user_es.establishment.id)

        return response

    def deleteTransparencyColaborativeUser(self, pk, user_id):
        user_es = UserEstablishmentExtended.objects.filter(
            user_id=user_id, is_active=True).last()

        response = TransparencyColab.objects.get(
            establishment_id=user_es.establishment.id, id=pk).delete()

        return response

    def update_transparency_colaborative(self, pk, user_id, newfiles):

        user_es = UserEstablishmentExtended.objects.get(user_id=user_id)

        response = TransparencyColab.objects.filter(
            id=pk).first()
        if not response:
            raise ValueError("No se encontro la publicacion de transparencia colaborativa")

        file_instances = FilePublication.objects.filter(id__in=newfiles)

        response.files.set(file_instances)

        return response

    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        return TransparencyColab.objects.filter(year=year, month=month, establishment_id=establishment_id, status=StatusNumeral.APROVED)

    
    def get_by_year(self, year: int, establishment_id: int):
        return TransparencyColab.objects.filter(year=year, establishment_id=establishment_id, status=StatusNumeral.APROVED)
    
    def get_by_year_all(self, year: int, establishment_id: int):
        return TransparencyColab.objects.filter(year=year, establishment_id=establishment_id)
    
    def get_months_by_year(self, year: int, establishment_id: int):
        return TransparencyColab.objects.filter(year=year, establishment_id=establishment_id, status=StatusNumeral.APROVED).values('month').distinct()
    
    def get_all_year_month(self,year: int, month: int):
        return TransparencyColab.objects.filter(year=year, month=month) 
    
    def approve_transparency_colaborative(self, id):
        obj = TransparencyColab.objects.get(id=id)
        obj.status = StatusNumeral.APROVED
        obj.published = True
        obj.published_at = datetime.now()
        obj.updated_at = datetime.now()
        obj.save()
        return obj
