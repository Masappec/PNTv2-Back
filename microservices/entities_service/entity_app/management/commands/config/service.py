
from entity_app.management.commands.config.numerals.main import NumeralServiceData


class ConfigDataService:

    def __init__(self) -> None:
        self.numeral_service = NumeralServiceData()

    def assign_numerals(self):
        self.numeral_service.asign_numeral_to_establishments()

    def list_templates(self):
        return self.numeral_service.read_json_generate()

    def generate_file(self):
        return self.numeral_service.generate_file_json()
    
    def generate_permissions(self):
        self.numeral_service.generate_permissions()
