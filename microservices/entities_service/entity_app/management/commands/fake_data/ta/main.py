
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entity_app.domain.models import EstablishmentExtended
from entity_app.domain.services.template_service import TemplateService
from entity_app.adapters.impl.template_file_impl import TemplateFileImpl
from entity_app.utils.functions import progress_bar
from typing import List
from faker import Faker
import csv
import io
from django.core.files.base import ContentFile
from entity_app.domain.services.file_publication_service import FilePublicationService
from entity_app.adapters.impl.file_publication_impl import FilePublicationImpl
from datetime import datetime
from django.utils import timezone


class TransparencyActiveFakeData:

    def __init__(self) -> None:

        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

        self.template_service = TemplateService(
            template_repo=TemplateFileImpl()
        )
        self.faker = Faker()

        self.file_pub = FilePublicationService(
            FilePublicationImpl()
        )

    def generate_file_csv(self, namefile: str, colums: List[str], faker):
        with open('file.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(colums)  # Escribir los encabezados

            # Escribir las filas de datos
            for _ in range(100):
                writer.writerow([faker.text() for _ in colums])

        # Leer el contenido del archivo y crear un ContentFile
        with open('file.csv', 'rb') as file:
            csv_content = file.read()

        # Crear un objeto ContentFile y devolverlo
        file_name = f"{namefile}.csv"
        return ContentFile(csv_content, name=file_name)

    def create_fake_data(self):
        self.service.get_all().delete()
        list_establishment = EstablishmentExtended.objects.all()
        numeral_list = self.service.get_all().delete()
        anios = [_ for _ in range(2020, 2024)]
        meses = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        print("datos")
        for x, establishment in enumerate(list_establishment):
            print(progress_bar(x, len(list_establishment)), end='\r', flush=True)

            for anio in anios:
                for mes in meses:

                    for numeral in numeral_list:
                        templates = self.template_service.get_templates_by_numeral(
                            numeral.id)
                        file_list = []
                        print("Creando archivos...")
                        for template in templates:
                            file = self.generate_file_csv(
                                template.name, [x.name for x in template.columns.all()], self.faker)
                            file_pub_saved = self.file_pub.save(
                                template.name, numeral.description, file)
                            file_list.append(file_pub_saved.id)
                        print("Creando transparencia")
                        self.service.create_transparency(
                            establishment_id=establishment.id,
                            numeral_id=numeral.id,
                            files=file_list,
                            month=mes,
                            year=anio,
                            fecha_actual=timezone.now()
                        )
