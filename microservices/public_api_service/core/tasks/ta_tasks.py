import pandas as pd
from core.models import Metadata, CSVData


def on_update_ta(filepaths, date, month, year, user, establishment_identification):

    file = None
    for filepath in filepaths:
        try:
            with open(filepath, 'r') as file:
                content = file.read()

                print('Content:', content)
        except Exception as e:
            print('Error reading file:', e)
            continue
        '''columns = csv.columns.tolist()
        data = csv.values.tolist()

        metadata = Metadata(
            filename=filepath,
            columns=columns,
            month=month,
            year=year,
            user_upload=user,
            date_upload=date,
            path=filepath,
            establishment_identification=establishment_identification
        )
        csv_data = CSVData(metadata=metadata, data=data)
        csv_data.save()
        print('CSVData saved:', csv_data)'''
