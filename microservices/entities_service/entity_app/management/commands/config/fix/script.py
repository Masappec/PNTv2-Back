from entity_app.domain.models import TransparencyActive, TransparencyColab
import os
import json
class ScriptService:

    def fix_month(self):

        ta = TransparencyActive.objects.all()

        list_to_fix = []
        dir = os.path.dirname(__file__)
        dir = os.path.join(dir, 'public_api_service.c_s_v_data.json')
        with open(dir, encoding='utf-8') as file:
            json_data = json.load(file)

            for item in json_data:
                metadata = item['metadata']
                extractedMonth = item['extractedMonth']
                numeral = metadata['numeral']
                month = metadata['month']
                year = metadata['year']
                columnsDate = item['columnsDate']

                establishment_identification = metadata['establishment_identification']
                establishment_name = metadata['establishment_name']

                mensaje = ''
                if int(extractedMonth) >= 9:
                    try:
                        ta.filter(numeral__name=numeral,
                                  establishment__identification=establishment_identification,
                                  month=month,
                                  year=year,
                                  ).update(month=extractedMonth)
                    except Exception as e:
                        print(e.__str__())
                        mensaje = e.__str__()
                else:
                    mensaje = 'Es un mes menor a septiembre'
                list_to_fix.append({
                    'numeral': numeral,
                    'mes_actual': month,
                    'anio': year,
                    'identificacion': establishment_identification,
                    'nombre': establishment_name,
                    'mes_metadato': extractedMonth,
                    'fecha_metadato': columnsDate,
                    'mensaje': mensaje
                })

        # crea un archivo json con list_to_fix
        path = os.path.dirname(__file__)
        path = os.path.join(path, 'list_to_fix.json')

        with open(path, 'w') as file:
            json.dump(list_to_fix, file, indent=4)
        
        print(list_to_fix)
                    
    def fix_month_colab(self):
        ta = TransparencyColab.objects.all()

        list_to_fix = []
        dir = os.path.dirname(__file__)
        dir = os.path.join(dir, 'public_api_service_colab.c_s_v_data.json')
        with open(dir, encoding='utf-8') as file:
            json_data = json.load(file)

            for item in json_data:
                metadata = item['metadata']
                extractedMonth = item['extractedMonth']
                numeral = metadata['numeral']
                month = metadata['month']
                year = metadata['year']
                columnsDate = item['columnsDate']

                establishment_identification = metadata['establishment_identification']
                establishment_name = metadata['establishment_name']

                mensaje = ''
                if int(extractedMonth) >= 9:
                    try:
                        ta.filter(numeral__name=numeral,
                                  establishment__identification=establishment_identification,
                                  month=month,
                                  year=year,
                                  ).update(month=extractedMonth)
                    except Exception as e:
                        print(e.__str__())
                        mensaje = e.__str__()
                else:
                    mensaje = 'Es un mes menor a septiembre'
                list_to_fix.append({
                    'numeral': numeral,
                    'mes_actual': month,
                    'anio': year,
                    'identificacion': establishment_identification,
                    'nombre': establishment_name,
                    'mes_metadato': extractedMonth,
                    'fecha_metadato': columnsDate,
                    'mensaje': mensaje
                })

        # crea un archivo json con list_to_fix
        path = os.path.dirname(__file__)
        path = os.path.join(path, 'list_to_fix_colab.json')

        with open(path, 'w') as file:
            json.dump(list_to_fix, file, indent=4)

        print(list_to_fix)
        
        