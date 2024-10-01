
from typing import Any
from .configure_init.service import ConfigureService
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    def __init__(self, *args, **kwargs):
        self.service = ConfigureService()
        super(Command, self).__init__(*args, **kwargs)
    help = '''Generate fake data for the establishment model.
    Usage: python manage.py config_data --establishment --quantity 10'''

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument(
            '--all', help='Generate fake data for the establishment model', action='store_true')
        parser.add_argument(
            '--establishment', help='Generate fake data for the establishment model', action='store_true')
        parser.add_argument(
            '--fo', help='Generate fake data for the function organization model', action='store_true')
        parser.add_argument(
            '--ti', help='Generate fake data for the type institution model', action='store_true')
        parser.add_argument(
            '--quantity', help='Quantity of data to generate', type=int)

        parser.add_argument(
            '--type', help='Type of data to generate', action='store_true')
        
        parser.add_argument(
            '--auto_create_establishment',
            help='Generate Users and Establishment',action='store_true'
        )

    def handle(self, *args: Any, **options: Any) -> str | None:

        all = options.get('all', False)
        quantity = options.get('quantity', 0)

        if all:
            self.service.create_type_institution()
            self.service.create_function_organization()
            self.service.create_establishment()
        if options.get('establishment', False):
            if quantity:
                self.service.create_establishment_quantity(quantity)
        if options.get('fo', False):
            self.service.create_function_organization()

        if options.get('ti', False):
            self.service.create_type_institution()

        if options.get('type', False):
            self.service.create_type_organization()

        if options.get('auto_create_establishment', False):
            self.service.create_establishment_user()