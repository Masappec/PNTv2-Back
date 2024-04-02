
from typing import Any
from .configure_init.service import ConfigureService
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    def __init__(self):
        self.service = ConfigureService()

    help = '''Generate fake data for the establishment model.
    Usage: python manage.py config_data --establishment --quantity 10'''

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument(
            '--all', help='Generate fake data for the establishment model', action='store_true')

    def handle(self, *args: Any, **options: Any) -> str | None:

        all = options.get('all', False)
        if all:
            self.service.create_function_organization()
            self.service.create_type_institution()
            self.service.create_function_organization()
            self.service.create_establishment()
