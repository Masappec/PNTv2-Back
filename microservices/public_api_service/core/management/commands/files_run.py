from typing import Any
from django.core.management.base import BaseCommand
from core.models import TransparencyActive, CSVData, Metadata, FilePublication
from core.tasks.ta_tasks import on_update_ta
from pathlib import Path


class Command(BaseCommand):

    def add_arguments(self, parser):

        parser.add_argument(
            '-run_save_csv', help='Generar archivo csv', action='store_true')

    def handle(self, *args, **options):
        if options.get('run_save_csv', False):
            self.run_generate_file()

    def run_generate_file(self):
        all = TransparencyActive.objects.all()
        list_files = FilePublication.objects.all()
        for x, item in enumerate(all):
            print(f'Procesando {x + 1} de {len(all)}', end='\r')
            files = list_files.filter(
                transparency_active=item, name__icontains='Metadatos')
            files_path = [f"/code/media{file.url_download.url.replace('%20', ' ')}"
                          for file in files]
            on_update_ta(
                files_path,
                item.created_at.strftime('%Y-%m-%d'),
                item.month,
                item.year,
                item.establishment_id,
                item.establishment.identification,
                item.numeral.name,
                item.establishment.name,
                item.numeral.description
            )
