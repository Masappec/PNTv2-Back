
from entity_app.domain.models import EstablishmentExtended
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entity_app.utils.functions import progress_bar


class NumeralServiceData:

    def __init__(self) -> None:
        self.service = NumeralService(numeral_repository=NumeralImpl())

    def asign_numeral_to_establishments(self):

        establistments = EstablishmentExtended.objects.all()
        defaults_numerals = self.service.get_by_default(True)
        print(establistments.count())
        for x, establistment in enumerate(establistments):
            print(progress_bar(x, len(establistments)))
            n = self.service.get_by_entity(establistment.id)
            if n.count() == 0:
                self.service.asign_numeral_to_establishment(
                    defaults_numerals, establistment.id)
