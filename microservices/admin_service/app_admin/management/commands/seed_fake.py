
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
            '--establishment', help='Generate fake data for the establishment model', action='store_true')
        parser.add_argument(
            '--quantity', help='Quantity of fake data to generate', type=int)

    def handle(self, *args: Any, **options: Any) -> str | None:

        establishment = options.get('establishment', False)
        quantity = options.get('quantity', 0)

        if establishment:
            if 'quantity' in options:
                return self.fake_data_service.generate_fake_establishment(quantity)

            return self.fake_data_service.generate_fake_establishment(1)
        return self.fake_data_service.generate_fake_establishment(1)
