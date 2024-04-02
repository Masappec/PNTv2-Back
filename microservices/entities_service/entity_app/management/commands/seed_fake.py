
from typing import Any
from .fake_data.service import FakeDataService
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    def __init__(self):
        self.fake_data_service = FakeDataService()

    help = '''Generate fake data for the establishment model.
    Usage: python manage.py seed_fake --establishment --quantity 10'''

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument(
            '-ta', help='Generar datos de transparencia activa', action='store_true')

    def handle(self, *args: Any, **options: Any) -> str | None:

        ta = options.get('ta', False)
        print("handle")
        if ta:
            self.fake_data_service.generate_fake_ta()
