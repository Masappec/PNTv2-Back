
from typing import Any
from .config.service import ConfigDataService
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    def __init__(self):
        self.config_service = ConfigDataService()

    help = '''Generate fake data for the establishment model.
    Usage: python manage.py seed_fake --establishment --quantity 10'''

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument(
            '-an', help='Generar datos de transparencia activa', action='store_true')

        parser.add_argument(
            '-list_templates', help='Listar plantillas', action='store_true')

        parser.add_argument(
            '-generate_file', help='Generar archivo', action='store_true')
        
        parser.add_argument(
            '-generate_permissions', help='Generar permisos', action='store_true')
        
        parser.add_argument(
            '-update_data_numeral', help='Actualizar datos de numeral', action='store_true')
        
        parser.add_argument(
            '-an_especific', help='Generar datos de transparencia activa de un establecimiento', action='store_true')

        parser.add_argument(
            '-update_month_publications', help='Toda la información cargada en las 3 transparencias en el mes en curso debe aparece como el mes anterior ',
            action='store_true'
        )
        parser.add_argument(
            '-fix_month', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        
        parser.add_argument(
            '-fix_month_colab', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        

        parser.add_argument(
            '-fix_metadatos', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )

        parser.add_argument(
            '-fix_diccionario', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        parser.add_argument(
            '-move_september', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        parser.add_argument(
            '-fix_september', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        parser.add_argument(
            '-save_pnt1',   help='Guarda los datos de transparencia activa en un archivo', action='store_true'
        )
        parser.add_argument(
            '-fix_colab_september', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        parser.add_argument(
            '-fix_focal_september', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        parser.add_argument(
            '-fix_focal_files', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        parser.add_argument(
            '-fix_presidencia', help='Arregla todas las publicaciones mal movida entre meses', action='store_true'
        )
        parser.add_argument(
            '-generate_anual_report', help='Generar reporte anual', action='store_true'
        )
        parser.add_argument(
            '-fix_active_files', help='Generar reporte anual', action='store_true'
        )

        parser.add_argument(
            '-generate_topics', help='Generar reporte anual', action='store_true'
        )


    def handle(self, *args: Any, **options: Any) -> str | None:

        ta = options.get('an', False)
        if ta:
            print('Asignando numerals a los establecimientos')
            self.config_service.assign_numerals()

        list_templates = options.get('list_templates', False)
        if list_templates:
            print(self.config_service.list_templates())

        generate_file = options.get('generate_file', False)
        if generate_file:
            print(self.config_service.generate_file())
            
        generate_permissions = options.get('generate_permissions', False)
        if generate_permissions:
            print(self.config_service.generate_permissions())
            
        update_data_numeral = options.get('update_data_numeral', False)
        if update_data_numeral:
            print(self.config_service.update_columns_numeral())
        an_especific = options.get('an_especific', False)
        if an_especific:
            print('Asignando numerals a los establecimientos')
            print(self.config_service.asign_numeral_especific())
            
        update_month_publications = options.get('update_month_publications')
        if update_month_publications:
            self.config_service.update_month_transparency_active()
            
        if options.get('fix_month', False):
            self.config_service.fix_month()
        if options.get('fix_month_colab', False):
            self.config_service.fix_month_colab()

        if options.get('fix_metadatos', False):
            self.config_service.fix_metadatos()

        if options.get('fix_diccionario', False):
            self.config_service.fix_diccionario()
            
        if options.get('move_september', False):
            self.config_service.move_september()
        if options.get('fix_september', False):
            self.config_service.fix_september()
        if options.get('save_pnt1', False):
            self.config_service.save_pnt1()
        if options.get('fix_colab_september', False):
            self.config_service.fix_colab_september()
        if options.get('fix_focal_september', False):
            self.config_service.fix_focal_september()
        if options.get('fix_focal_files', False):
            self.config_service.fix_focal_files()
        if options.get('fix_presidencia', False):
            self.config_service.fix_presidencia()
        if options.get('generate_anual_report', False):
            self.config_service.generate_anual_report()

        if options.get('fix_active_files', False):
            self.config_service.fix_active_files()


        if options.get('generate_topics', False):
            self.config_service.generate_topics()
