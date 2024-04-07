
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

    def handle(self, *args: Any, **options: Any) -> str | None:

        ta = options.get('an', False)
        if ta:
            print('Asignando numerals a los establecimientos')
            self.config_service.assign_numerals()
