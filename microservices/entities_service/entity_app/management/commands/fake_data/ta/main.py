
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

        for establishment in list_establishment:
            for numeral in numeral_list:

                self.service.create_transparency(
                    establishment_id=establishment.id,
                    numeral_id=numeral.id,
                    files="",
                    month=1,
                    year=2021,
                    fecha_actual="2021-01-01",
                    status="ingress"
                )
