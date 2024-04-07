
from typing import Any
from .config.service import ConfigService
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    def __init__(self):
        self.service = ConfigService()

    help = '''Generate fake data for the establishment model.
    Usage: python manage.py seed_fake --establishment --quantity 10'''

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument(
            '--citizen', help='Generate fake data for the establishment model', action='store_true')

    def handle(self, *args: Any, **options: Any) -> str | None:

        citizen = options.get('citizen', False)

        if citizen:
            self.service.asign_permission_to_citizen()
            print('Permissions assigned to citizen role')
            return
