import datetime
from entity_app.domain.models import TransparencyActive, TransparencyColab, FilePublication
import os
import json
from django.db.models import Q
import pandas as pd
from django.core.files.base import ContentFile
import calendar

from entity_app.domain.models.transparency_active import Numeral

class ScriptService:


    def obtener_ultimo_dia_mes(self,anio, mes):
        # Obtener el último día del mes
        _, ultimo_dia = calendar.monthrange(anio, mes)
        return ultimo_dia

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
        list_files = FilePublication.objects.all()

        list_to_fix = []
        dir = os.path.dirname(__file__)
        dir = os.path.join(dir, 'public_api_service_colab.c_s_v_data.json')
        with open(dir, encoding='utf-8') as file:
            json_data = json.load(file)

            for item in json_data:
                metadata = item['metadata']
                numeral = metadata['numeral']
                month = metadata['month']
                year = metadata['year']
                columnsDate = item['columnsDate']
                extractedMonth = item['extractedMonth']

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
        
        
        
    def fix_metadatos(self):
        ta = TransparencyActive.objects.all()
        dir = os.path.dirname(__file__)
        dir = os.path.join(dir, 'ta_metadatos_csv.json')
        list_to_fix = []

        with open(dir, encoding='utf-8') as file:
            json_data = json.load(file)
            for _json in json_data:  
                metadata = _json['metadata']
                numeral = metadata['numeral']
                month = metadata['month']
                year = metadata['year']
                file_name = metadata['filename']
                path = metadata['path']
                establishment_identification = metadata['establishment_identification']
                establishment_name = metadata['establishment_name']
                publications = ta.filter(numeral__name=numeral, establishment__identification=establishment_identification,
                           month=month,year=year)
                object_ = {
                    'numeral': numeral,
                    'month': month,
                    'year': year,
                    'establishment_identification': establishment_identification,
                    'establishment_name': establishment_name,
                    'filename': file_name,
                    'url_actual': path,
                    'url_nueva': '',
                    'mensaje': ''
                }
                fecha = self.obtener_ultimo_dia_mes(int(year), int(month))
                fecha_ = f"{year}-{month}-{fecha}"
                if publications.exists():
                    publication = publications.first()
                    files_publication = publication.files.filter(name=file_name).first()
                    csv_ant = ta.filter(
                                numeral__name=numeral, 
                                establishment__identification=establishment_identification,
                                year=year).exclude(id=publication.id)
                    if csv_ant:
                        for csv in csv_ant:
                            url_path = csv.files.filter(name=file_name).first()
                            try:
                                if url_path:
                                    csv_content = pd.read_csv("/code"+url_path.url_download.url.replace('%20', ' '), sep=';')
                                    csv_content.values[1] = fecha_
                                    new_file_pub = FilePublication.objects.create(
                                        name=file_name,
                                        description=file_name,
                                        is_active=True,
                                        is_colab=False
                                    )
                                    csv_content.drop(
                                        csv_content.columns[2], axis=1, inplace=True)
                                    csv_content_new = ContentFile(csv_content.to_csv(index=False,sep=';', header=True))
                                    new_file_pub.url_download.save(file_name+".csv", csv_content_new)
                                    object_['url_nueva'] = new_file_pub.url_download.url
                                    publication.files.remove(files_publication)
                                    publication.files.add(new_file_pub)
                                    object_['mensaje'] = 'Se ha actualizado el metadato'
                                    break
                            except Exception as e:
                                object_['mensaje'] = e.__str__()
                                continue

                    else:
                        object_['mensaje'] = 'No hay archivos anteriores'
                    
                    list_to_fix.append(object_)

        path = os.path.dirname(__file__)
        path = os.path.join(path, 'fix_metadatos.json')

        with open(path, 'w') as file:
            json.dump(list_to_fix, file, indent=4)

        print(list_to_fix)

    def fix_diccionario(self):
        dir = os.path.dirname(__file__)
        dir = os.path.join(dir, 'ta_diccionario_csv.json')
        list_to_fix = []
        numerales = Numeral.objects.all()

        with open(dir, encoding='utf-8') as file:
            json_data = json.load(file)
            for _json in json_data[:10]:
                metadata = _json['metadata']
                numeral = metadata['numeral']
                month = metadata['month']
                year = metadata['year']
                file_name = metadata['filename']
                path = metadata['path']
                establishment_identification = metadata['establishment_identification']
                establishment_name = metadata['establishment_name']
                object_ = {
                    'numeral': numeral,
                    'month': month,
                    'year': year,
                    'establishment_identification': establishment_identification,
                    'establishment_name': establishment_name,
                    'filename': file_name,
                    'url_actual': path,
                    'url_nueva': '',
                    'mensaje': ''
                }

                publications = TransparencyActive.objects.filter(numeral__name=numeral, establishment__identification=establishment_identification,
                           month=month,year=year)
                
                if publications.exists():
                    publication = publications.first()
                    url_path = publication.files.filter(name__icontains=file_name).first()
                    if url_path:
                        numeral = numerales.filter(name=numeral)
                        if numeral.exists():
                            numeral = numeral.first()
                            diccionario_dict = {}
                            for i in numeral.templates.all():
                                if i.name.lower() == file_name.lower():
                                    for j in i.columns.all():
                                        diccionario_dict[j.name] = j.value.replace('{INSTITUCION}', establishment_name)
                                    break
                            df = pd.DataFrame.from_dict(diccionario_dict, orient='index')
                            new_file_pub = FilePublication.objects.create(
                                name=file_name,
                                description=file_name,
                                is_active=True,
                                is_colab=False
                            )

                            csv_content_new = ContentFile(df.to_csv(index=True,sep=';', header=False))
                           
                            new_file_pub.url_download.save(file_name+".csv", csv_content_new)
                            publication.files.remove(url_path)
                            publication.files.add(new_file_pub)

                            object_['url_nueva'] = new_file_pub.url_download.url
                            object_['mensaje'] = 'Se ha actualizado el diccionario'


                    else:
                        object_['mensaje'] = 'No existe el archivo'


                list_to_fix.append(object_)
        path = os.path.dirname(__file__)
        path = os.path.join(path, 'fix_diccionario.json')

        with open(path, 'w') as file:
            json.dump(list_to_fix, file, indent=4)

        print(list_to_fix)
                    
                    