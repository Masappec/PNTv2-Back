from entity_app.ports.repositories.anual_report_reposity import AnualReportReposity
import openpyxl

from entity_app.domain.models.establishment import EstablishmentExtended
from entity_app.domain.models.transparecy_colab import TransparencyColab
from entity_app.domain.models.transparecy_foc import TransparencyFocal
from entity_app.domain.models.transparency_active import TransparencyActive

class AnualReportService:
    def __init__(self, anual_report_repository:AnualReportReposity):
        self.anual_report_repository = anual_report_repository

    def create(self, anual_report: dict):
        return self.anual_report_repository.add(**anual_report)

    def get(self, establishment_id: int, year: int, month: int):
        return self.anual_report_repository.get(establishment_id, year, month)

    def get_all(self):
        return self.anual_report_repository.get_all()

    def update(self, anual_report: dict):
        return self.anual_report_repository.update(**anual_report)

    def delete(self, anual_report_id):
        return self.anual_report_repository.delete(anual_report_id)
    
    
    def generate(self, year):

        anual_report = self.anual_report_repository.get_all()
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "T.A-F-C"
        ws.append([
            "Función a la que pertenece",
            "Tipo",
            "Nombre Entidad",
            "Marco Legal",
            "Enero",
            "Febreo",
            "Marzo",
            "Abril",
            "Mayo",
            "Junio",
            "Julio",
            "Agosto",
            "Septiembre",
            "Octubre",
            "Noviembre",
            "Diciembre"
        ])
        
        establishments = EstablishmentExtended.objects.filter(is_active=True).all()
        tc = TransparencyColab.objects.filter(establishment__is_active=True).all()
        tf = TransparencyFocal.objects.filter(establishment__is_active=True).all()
        ta = TransparencyActive.objects.filter(establishment__is_active=True).all()
        for establishment in establishments:
            type_institution = ""
            nombre = establishment.name
            
            #TC = T. Colaborativa
            tc_ = tc.filter(establishment=establishment).all()
            if tc_:
                list_tc = {
                    'enero': False,
                    'febrero': False,
                    'marzo': False,
                    'abril': False,
                    'mayo': False,
                    'junio': False,
                    'julio': False,
                    'agosto': False,
                    'septiembre': False,
                    'octubre': False,
                    'noviembre': False,
                    'diciembre': False
                }
                for t in tc_:
                    if t.month == 1:
                        list_tc['enero'] = True
                    elif t.month == 2:
                        list_tc['febrero'] = True
                    elif t.month == 3:
                        list_tc['marzo'] = True
                    elif t.month == 4:
                        list_tc['abril'] = True
                    elif t.month == 5:
                        list_tc['mayo'] = True
                    elif t.month == 6:
                        list_tc['junio'] = True
                    elif t.month == 7:
                        list_tc['julio'] = True
                    elif t.month == 8:
                        list_tc['agosto'] = True
                    elif t.month == 9:
                        list_tc['septiembre'] = True
                    elif t.month == 10:
                        list_tc['octubre'] = True
                    elif t.month == 11:
                        list_tc['noviembre'] = True
                    elif t.month == 12:
                        list_tc['diciembre'] = True
                ws.append([
                    "FUNCIÓN EJECUTIVA",
                    "Pública",
                    nombre,
                    "Art. 4, número 9 T. Colaborativa",
                    'si' if list_tc['enero'] else 'no',
                    'si' if list_tc['febrero'] else 'no',
                    'si' if list_tc['marzo'] else 'no',
                    'si' if list_tc['abril'] else 'no',
                    'si' if list_tc['mayo'] else 'no',
                    'si' if list_tc['junio'] else 'no',
                    'si' if list_tc['julio'] else 'no',
                    'si' if list_tc['agosto'] else 'no',
                    'si' if list_tc['septiembre'] else 'no',
                    'si' if list_tc['octubre'] else 'no',
                    'si' if list_tc['noviembre'] else 'no',
                    'si' if list_tc['diciembre'] else 'no'
                ])
                
            tf_ = tf.filter(establishment=establishment).all()

            if tf_:
                list_tf = {
                    'enero': False,
                    'febrero': False,
                    'marzo': False,
                    'abril': False,
                    'mayo': False,
                    'junio': False,
                    'julio': False,
                    'agosto': False,
                    'septiembre': False,
                    'octubre': False,
                    'noviembre': False,
                    'diciembre': False
                }
                for t in tf_:
                    if t.month == 1:
                        list_tf['enero'] = True
                    elif t.month == 2:
                        list_tf['febrero'] = True
                    elif t.month == 3:
                        list_tf['marzo'] = True
                    elif t.month == 4:
                        list_tf['abril'] = True
                    elif t.month == 5:
                        list_tf['mayo'] = True
                    elif t.month == 6:
                        list_tf['junio'] = True
                    elif t.month == 7:
                        list_tf['julio'] = True
                    elif t.month == 8:
                        list_tf['agosto'] = True
                    elif t.month == 9:
                        list_tf['septiembre'] = True
                    elif t.month == 10:
                        list_tf['octubre'] = True
                    elif t.month == 11:
                        list_tf['noviembre'] = True
                    elif t.month == 12:
                        list_tf['diciembre'] = True
                ws.append([
                    "FUNCIÓN EJECUTIVA",
                    "Pública",
                    nombre,
                    "Art. 4 número 10 T. Focalizada",
                    'si' if list_tf['enero'] else 'no',
                    'si' if list_tf['febrero'] else 'no',
                    'si' if list_tf['marzo'] else 'no',
                    'si' if list_tf['abril'] else 'no',
                    'si' if list_tf['mayo'] else 'no',
                    'si' if list_tf['junio'] else 'no',
                    'si' if list_tf['julio'] else 'no',
                    'si' if list_tf['agosto'] else 'no',
                    'si' if list_tf['septiembre'] else 'no',
                    'si' if list_tf['octubre'] else 'no',
                    'si' if list_tf['noviembre'] else 'no',
                    'si' if list_tf['diciembre'] else 'no'
                ])
                    
            
            
            #TA = T. Activa
            ta_ = ta.filter(establishment=establishment).all()
            
            if ta_:
                #filtrar los numerales  por defecto
                publications = ta_.filter(numeral__is_default=True).all().order_by('numeral__name')
                
                for publication in publications:
                    list_meses = {
                        'enero': False,
                        'febrero': False,
                        'marzo': False,
                        'abril': False,
                        'mayo': False,
                        'junio': False,
                        'julio': False,
                        'agosto': False,
                        'septiembre': False,
                        'octubre': False,
                        'noviembre': False,
                        'diciembre': False
                    }
                    if publication.month == 1:
                        list_meses['enero'] = True
                    elif publication.month == 2:
                        list_meses['febrero'] = True
                    elif publication.month == 3:
                        list_meses['marzo'] = True
                    elif publication.month == 4:
                        list_meses['abril'] = True
                    elif publication.month == 5:
                        list_meses['mayo'] = True
                    elif publication.month == 6:
                        list_meses['junio'] = True
                    elif publication.month == 7:
                        list_meses['julio'] = True
                    elif publication.month == 8:
                        list_meses['agosto'] = True
                    elif publication.month == 9:
                        list_meses['septiembre'] = True
                    elif publication.month == 10:
                        list_meses['octubre'] = Trues
                    elif publication.month == 11:
                        list_meses['noviembre'] = True
                    elif publication.month == 12:
                        list_meses['diciembre'] = True
                    
                    
            
            