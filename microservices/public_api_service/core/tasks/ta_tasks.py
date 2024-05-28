import pandas as pd
from core.models import Metadata, CSVData


def on_update_ta(filepaths, date, month, year, user, establishment_identification):

    file = None
    for filepath in filepaths:
        try:
            with open(filepath, 'r') as file:
                content = file.read()

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

                )
                csv_data = CSVData(metadata=metadata, data=data)
                csv_data.save()
                print('CSVData saved:', csv_data)
        except Exception as e:
            print('Error reading file:', e)
            continue
