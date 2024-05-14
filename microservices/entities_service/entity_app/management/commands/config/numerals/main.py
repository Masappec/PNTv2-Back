
from entity_app.domain.models import EstablishmentExtended
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entity_app.utils.functions import progress_bar
import os
import pandas as pd
import re
import json
from entity_app.models import TemplateFile, Numeral, ColumnFile


class NumeralServiceData:

    def __init__(self) -> None:
        self.service = NumeralService(numeral_repository=NumeralImpl())

    def asign_numeral_to_establishments(self):

        establistments = EstablishmentExtended.objects.all()
        defaults_numerals = self.service.get_by_default(True)
        print(establistments.count())
        for x, establistment in enumerate(establistments):
            print(progress_bar(x, len(establistments)))
            n = self.service.get_by_entity(establistment.id)
            if n.count() == 0:
                self.service.asign_numeral_to_establishment(
                    defaults_numerals, establistment.id)

    def extract_numeral_number(self, file_name):
        # Utilizamos una expresión regular para encontrar cualquier número,
        # ya sea entero o decimal, al principio del nombre del archivo.
        match = re.match(r'^\d+(\.\d+)?', file_name)
        if match:
            return match.group(0)
        else:
            return None

    def generate_file_json(self):
        # directorio actual
        dir = os.path.dirname(os.path.dirname(__file__))
        dir = os.path.join(dir, 'DatasetsDPE')

        list_final = []
        for root, dirs, files in os.walk(dir):
            for file in files:
                if file.endswith('.xlsx'):
                    df = pd.ExcelFile(os.path.join(root, file))

                    numeral_name = re.sub(r'Art.', '', file)
                    numeral_name = numeral_name.replace('.xlsx', '')

                    number = self.extract_numeral_number(file)

                    numeral_data = {
                        'name': numeral_name,
                        'number': self.extract_numeral_number(file),
                        'templates': []
                    }

                    if file.startswith("ART") or re.search("[0-9].", file):
                        list_sheets = df.sheet_names
                        list_templates = []

                        for sheet in list_sheets:
                            if sheet.lower().find('conjunto de datos') != -1 or \
                                    sheet.lower().find('metadatos') != -1 or \
                                    sheet.lower().find('diccionario') != -1:

                                template = {
                                    'name': sheet,
                                    'description': numeral_name,
                                    "vertical_template": False,
                                    "max_insert": None,
                                    'columns': []
                                }

                                dataframe = df.parse(sheet, encode='')

                                if sheet.lower().find('conjunto de datos') != -1:
                                    data = dataframe.head().to_json()
                                    dict_data = json.loads(data)
                                    list_ids_column = []
                                    for k in dict_data:
                                        column = {
                                            "name": k,
                                            "type": "str",
                                            "format": None,
                                            "regex": None
                                        }

                                        list_ids_column.append(column)
                                    template['columns'] = list_ids_column

                                else:
                                    template = {
                                        'name': sheet,
                                        'description': numeral_name,
                                        "vertical_template": True,
                                        "max_insert": 1,
                                        'columns': []
                                    }

                                    columns = dataframe.iloc[:, 0].to_list()
                                    list_columns = []
                                    for column in columns:
                                        column_save = {
                                            "name": column,
                                            "type": "str",
                                            "format": None,
                                            "regex": None
                                        }
                                        list_columns.append(column_save)

                                    template['columns'] = list_columns

                                list_templates.append(template)
                            numeral_data['templates'] = list_templates
                            list_final.append(numeral_data)

        print(json.dumps(list_final, ensure_ascii=False))

    def read_json_generate(self):

        dir = os.path.dirname(__file__)
        dir = os.path.join(dir, 'test.json')
        with open(dir, encoding='utf-8') as file:
            data = json.load(file)
            for numeral in data:
                description = numeral['name']
                name = numeral['name']
                is_default = numeral['default']
                description = re.sub(r'[0-9]', '', description)

                description = description.replace('. ', '')
                description = description.replace('.', '')
                type = 'A'
                if description == 'Transparencia colaborativa':
                    type = 'C'
                if description == 'Transparencia focalizada':
                    type = 'F'
                numero = re.search(r'\d+', name)

                numeral_object = Numeral.objects.create(
                    name="Numeral " + numero.group() if numero else description,
                    description=description,
                    type_transparency=type,
                    is_default=is_default
                )

                for template in numeral['templates']:
                    template_object = TemplateFile.objects.create(
                        name=template['name'],
                        description=template['description'],
                        vertical_template=template['vertical_template'],
                        max_inserts=template['max_insert'],

                    )

                    numeral_object.templates.add(template_object)

                    for column in template['columns']:
                        column_object = ColumnFile.objects.create(
                            name=column['name'],
                            type=column['type'],
                            format=column['format'],
                            regex=column['regex'],
                        )
                        template_object.columns.add(column_object)
