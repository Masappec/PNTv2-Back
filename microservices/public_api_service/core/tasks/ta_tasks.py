import pandas as pd
from core.models import Metadata, CSVData
import chardet

from io import StringIO


def detect_encoding(file_path):
    with open(file_path, 'rb') as f:
        result = chardet.detect(f.read())
        return result['encoding']


def on_update_ta(filepaths, date, month, year, user, establishment_identification, numeral, establishment_name,
                 numeral_description):

    file = None
    for filepath in filepaths:
        try:
            encoding = detect_encoding(filepath)
            with open(filepath, 'r', encoding=encoding) as file:
                content = file.read()
                content = content.replace('\ufeff', '')
                print('Content:', content)
                csv = pd.read_csv(StringIO(content),
                                  # Trata correctamente los saltos de línea dentro de celdas
                                  delimiter=';', quotechar='"', lineterminator='\n',
                                  on_bad_lines='skip')

                # remplazar los NaN por '', para evitar problemas con el tipo de dato,
                # convertir los numeros a string
                csv = csv.applymap(lambda x: str(x) if pd.notnull(x) else '')
                csv = csv.fillna('')
                data = csv.values.tolist()
                columns = csv.columns
                metadata = Metadata(
                    filename=filepath,
                    columns=columns,
                    month=str(month),
                    year=str(year),
                    user_upload=str(user),
                    date_upload=date,
                    path=filepath,
                    establishment_identification=establishment_identification,
                    numeral=numeral,
                    establishment_name=establishment_name,
                    numeral_description=numeral_description

                )
                csv_data = CSVData(metadata=metadata, data=data)
                csv_data.save()
                print('CSVData saved:', data)
        except Exception as e:
            print('Error reading file:', e)
            continue


def on_delete_ta(month, year, establishment_identification, numeral):
    try:

        csv_data = CSVData.objects(
            metadata__month=str(month),
            metadata__year=str(year),
            metadata__establishment_identification=establishment_identification,
            metadata__numeral=numeral
        )
        csv_data.delete()
        print('CSVData deleted:', csv_data)
    except Exception as e:
        print('Error deleting file:', e)


def on_replace_ta(filepaths, date, month, year, user, establishment_identification, numeral, establishment_name,
                  numeral_description):
    on_delete_ta(month, year, establishment_identification, numeral)
    on_update_ta(filepaths, date, month, year, user, establishment_identification,
                 numeral, establishment_name, numeral_description)
