from entity_app.domain.models.publication import FilePublication
from entity_app.ports.repositories.transparency_focus_repository import TransparencyFocusRepository
from entity_app.domain.models.transparecy_foc import TransparencyFocal

from entity_app.domain.models.establishment import UserEstablishmentExtended


class TransparencyFocalImpl(TransparencyFocusRepository):

    def createTransparencyFocus(self, establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha, status="ingress"):
        file_instances = FilePublication.objects.filter(id__in=files)

        response = TransparencyFocal.objects.create(establishment_id=establishment_id,
                                                    numeral_id=numeral_id,
                                                    month=month,
                                                    year=year,
                                                    status=status,
                                                    published=True,
                                                    max_date_to_publish=max_fecha,
                                                    published_at=fecha_actual if status == "ingress" else None)

        response.files.set(file_instances)

        return response

    def getTransparencyFocusUser(self, user_id):

        user_es = UserEstablishmentExtended.objects.filter(
            user_id=user_id, is_active=True).first()
        if not user_es:
            raise ValueError("El usuario no tiene establecimiento")
        response = TransparencyFocal.objects.filter(
            establishment_id=user_es.establishment.id)

        return response

    def deleteTransparencyFocusUser(self, pk, user_id):
        user_es = UserEstablishmentExtended.objects.filter(
            user_id=user_id).last()
        if not user_es:
            raise ValueError("El usuario no tiene establecimiento")
        response = TransparencyFocal.objects.get(
            establishment_id=user_es.establishment.id, id=pk).delete()

        return response

    def update_transparency_focus(self, pk, user_id, newfiles):

        user_es = UserEstablishmentExtended.objects.filter(
            user_id=user_id).first()
        if not user_es:
            raise ValueError("El usuario no tiene establecimiento")
        response = TransparencyFocal.objects.get(id=pk)

        file_instances = FilePublication.objects.filter(id__in=newfiles)

        response.files.set(file_instances)

        return response

    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        response = TransparencyFocal.objects.filter(
            establishment_id=establishment_id, year=year, month=month)

        return response


    def get_by_year(self, year: int, establishment_id: int):
        response = TransparencyFocal.objects.filter(
            establishment_id=establishment_id, year=year)

        return response
    
    
    
    def get_months_by_year(self, year: int, establishment_id: int):
        response = TransparencyFocal.objects.filter(
            establishment_id=establishment_id, year=year).values('month').distinct()

        return response