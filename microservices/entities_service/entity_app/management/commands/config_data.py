
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
            print(self.config_service.update_data_numeral())
