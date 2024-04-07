
from entity_app.management.commands.config.numerals.main import NumeralServiceData


class ConfigDataService:

    def __init__(self) -> None:
        self.numeral_service = NumeralServiceData()

    def assign_numerals(self):
        self.numeral_service.asign_numeral_to_establishments()
