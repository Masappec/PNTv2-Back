
from entity_app.management.commands.config.numerals.main import NumeralServiceData
from entity_app.management.commands.config.fix.script import ScriptService

class ConfigDataService:

    def __init__(self) -> None:
        self.numeral_service = NumeralServiceData()
        self.fix_script = ScriptService()
    def assign_numerals(self):
        self.numeral_service.asign_numeral_to_establishments()

    def list_templates(self):
        return self.numeral_service.read_json_generate()

    def generate_file(self):
        return self.numeral_service.generate_file_json()

    def generate_permissions(self):
        self.numeral_service.generate_permissions()
        
    def update_data_numeral(self):
        self.numeral_service.update_data_numeral()
        
    def asign_numeral_especific(self):
        self.numeral_service.asign_numeral_especific()
        
    def update_columns_numeral(self):
        self.numeral_service.update_columns_numeral()

    def update_month_transparency_active(self):
        self.numeral_service.update_month_transparency_active()
        
    def fix_month(self):
        self.fix_script.fix_month()
        
    def fix_month_colab(self):
        self.fix_script.fix_month_colab()

    def fix_metadatos(self):
        self.fix_script.fix_metadatos()

    def fix_diccionario(self):
        self.fix_script.fix_diccionario()

    def move_september(self):
        self.fix_script.move_september()
        
    def fix_september(self):
        self.fix_script.fix_september()
        
    def save_pnt1(self):
        self.numeral_service.read_pnt1()
        
    def fix_colab_september(self):
        self.fix_script.fix_colab_september()

    
    def fix_focal_september(self):
        self.fix_script.fix_focal_september()
        
    def fix_focal_files(self):
        self.fix_script.fix_focal_files()
        
    def fix_presidencia(self):
        self.fix_script.fix_presidencia()
        
    def generate_anual_report(self):
        self.numeral_service.generate_anual_report()