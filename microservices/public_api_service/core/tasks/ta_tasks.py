import pandas as pd
from core.models import Metadata, CSVData
import chardet


def detect_encoding(file_path):
    with open(file_path, 'rb') as f:
        result = chardet.detect(f.read())
        return result['encoding']
    
def on_update_ta(filepaths, date, month, year, user, establishment_identification, numeral):

    file = None
    for filepath in filepaths:
        try:
            encoding = detect_encoding(filepath)
            with open(filepath, 'r', encoding=encoding) as file:
                content = file.read()
                content = content.replace('\ufeff', '')
                csv = pd.DataFrame([x.split(';')
                                   for x in content.split('\n') if x])
                data = csv.values.tolist()
                columns = data.pop(0)
                print(columns, data)
                metadata = Metadata(
                    filename=filepath,
                    columns=columns,
                    month=str(month),
                    year=str(year),
                    user_upload=str(user),
                    date_upload=date,
                    path=filepath,
                    establishment_identification=establishment_identification,
                    numeral=numeral

                )
                csv_data = CSVData(metadata=metadata, data=data)
                csv_data.save()
                print('CSVData saved:', csv_data)
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
            
        
        
def on_replace_ta(filepaths, date, month, year, user, establishment_identification, numeral):
    on_delete_ta(month, year, establishment_identification, numeral)
    on_update_ta(filepaths, date, month, year, user, establishment_identification, numeral)