
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entity_app.domain.models import EstablishmentExtended


class TransparencyActiveFakeData:

    def __init__(self) -> None:
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

    def create_fake_data(self):
        list_establishment = EstablishmentExtended.objects.all()
        numeral_list = self.service.get_all()
        anios = [2020, 2021, 2022, 2023, 2024]
        meses = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

        for establishment in list_establishment:
            for anio in anios:
                for mes in meses:
                    for numeral in numeral_list:
                        self.service.create_transparency(
                            establishment_id=establishment.id,
                            numeral_id=numeral.id,
                            files="",
                            month=mes,
                            year=anio,
                            fecha_actual=f"{anio}-{mes}-01",
                            status="ingress"
                        )
