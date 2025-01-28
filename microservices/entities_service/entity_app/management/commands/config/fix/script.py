from datetime import datetime, timezone as tz, timedelta
import shutil
from entity_app.domain.models import TransparencyActive, TransparencyColab, FilePublication
import os
import json
from django.db.models import Q
import pandas as pd
from django.core.files.base import ContentFile
import calendar
import re
from entity_app.domain.models.transparency_active import Numeral
from entity_app.utils.functions import get_day_for_publish
from django.utils import timezone
# import settings
from django.conf import settings

from entity_app.domain.models.transparecy_foc import TransparencyFocal
from entity_app.domain.models.establishment import EstablishmentExtended


class ScriptService:

    def obtener_ultimo_dia_mes(self, anio, mes):
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
                                         month=month, year=year)
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
                    files_publication = publication.files.filter(
                        name=file_name).first()
                    csv_ant = ta.filter(
                        numeral__name=numeral,
                        establishment__identification=establishment_identification,
                        year=year).exclude(id=publication.id)
                    if csv_ant:
                        for csv in csv_ant:
                            url_path = csv.files.filter(name=file_name).first()
                            try:
                                if url_path:
                                    csv_content = pd.read_csv(
                                        "/code"+url_path.url_download.url.replace('%20', ' '), sep=';')
                                    csv_content.values[1] = fecha_
                                    new_file_pub = FilePublication.objects.create(
                                        name=file_name,
                                        description=file_name,
                                        is_active=True,
                                        is_colab=False
                                    )
                                    csv_content.drop(
                                        csv_content.columns[2], axis=1, inplace=True)
                                    csv_content_new = ContentFile(
                                        csv_content.to_csv(index=False, sep=';', header=True))
                                    new_file_pub.url_download.save(
                                        file_name+".csv", csv_content_new)
                                    object_[
                                        'url_nueva'] = new_file_pub.url_download.url
                                    publication.files.remove(files_publication)
                                    publication.files.add(new_file_pub)
                                    object_[
                                        'mensaje'] = 'Se ha actualizado el metadato'
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
                                                                 month=month, year=year)

                if publications.exists():
                    publication = publications.first()
                    url_path = publication.files.filter(
                        name__icontains=file_name).first()
                    if url_path:
                        numeral = numerales.filter(name=numeral)
                        if numeral.exists():
                            numeral = numeral.first()
                            diccionario_dict = {}
                            for i in numeral.templates.all():
                                if i.name.lower() == file_name.lower():
                                    for j in i.columns.all():
                                        diccionario_dict[j.name] = j.value.replace(
                                            '{INSTITUCION}', establishment_name)
                                    break
                            df = pd.DataFrame.from_dict(
                                diccionario_dict, orient='index')
                            new_file_pub = FilePublication.objects.create(
                                name=file_name,
                                description=file_name,
                                is_active=True,
                                is_colab=False
                            )

                            csv_content_new = ContentFile(
                                df.to_csv(index=True, sep=';', header=False))

                            new_file_pub.url_download.save(
                                file_name+".csv", csv_content_new)
                            publication.files.remove(url_path)
                            publication.files.add(new_file_pub)

                            object_['url_nueva'] = new_file_pub.url_download.url
                            object_[
                                'mensaje'] = 'Se ha actualizado el diccionario'

                    else:
                        object_['mensaje'] = 'No existe el archivo'

                list_to_fix.append(object_)
        path = os.path.dirname(__file__)
        path = os.path.join(path, 'fix_diccionario.json')

        with open(path, 'w') as file:
            json.dump(list_to_fix, file, indent=4)

        print(list_to_fix)

    def move_september(self):
        lista_creada = []

        try:
            dir = os.path.dirname(__file__)
            dir = os.path.join(
                dir, 'public_api_service.c_s_v_data_13_1_2024.json')
            with open(dir, encoding='utf-8') as file:
                data = json.load(file)
                # data = [ item for item in data if item['establishment_identification'] == '1768151240001']
                for x, item in enumerate(data):
                    second_column = item['second_column']
                    print("Procesando: {} de {} entidad {} con fecha {}".format(
                        x, len(data), item['establishment_identification'], second_column))
                    if second_column:

                        date = second_column.strip()
                        # split / or -
                        month = ''
                        # yyyy/mm/dd
                        if re.search(r'\d{4}/\d{2}/\d{2}', date):
                            month_search = re.search(
                                r'\d{4}/\d{2}/\d{2}', date)
                            month_list = month_search.group().split('/')
                            if len(month_list) == 3:
                                month = month_list[1]
                        # yyyy mm dd
                        elif re.search(r'\d{4} \d{2} \d{2}', date):
                            month_search = re.search(
                                r'\d{4} \d{2} \d{2}', date)
                            month_list = month_search.group().split(' ')
                            if len(month_list) == 3:
                                month = month_list[1]
                        elif re.search(r'\d{4}-\d{2}-\d{2}', date):
                            month_search = re.search(
                                r'\d{4}-\d{2}-\d{2}', date)
                            month_list = month_search.group().split('-')
                            if len(month_list) == 3:
                                month = month_list[1]
                        # yyyy.mm.dd
                        elif re.search(r'\d{4}.\d{2}.\d{2}', date):
                            month_search = re.search(
                                r'\d{4}.\d{2}.\d{2}', date)
                            month_list = month_search.group().split('.')
                            if len(month_list) == 3:
                                month = month_list[1]
                        elif re.search(r'\d{2}/\d{2}/\d{4}', date):
                            month_search = re.search(
                                r'\d{2}/\d{2}/\d{4}', date)
                            month_list = month_search.group().split('/')
                            if len(month_list) == 3:
                                month = month_list[1]
                        elif re.search(r'\d{2}-\d{2}-\d{4}', date):
                            month_search = re.search(
                                r'\d{2}-\d{2}-\d{4}', date)
                            month_list = month_search.group().split('/')
                            if len(month_list) == 3:
                                month = month_list[1]
                        elif re.search(r'\d{1}.\d{2}.\d{4}', date):
                            month_search = re.search(
                                r'\d{1}.\d{2}.\d{4}', date)
                            month_list = month_search.group().split('.')
                            if len(month_list) == 3:
                                month = month_list[1]

                        else:
                            print('no se pudo extraer la fecha')
                            continue
                        if not month:
                            continue

                        month_int = int(month)
                        month_metadata = item['month']
                        month_metadata_int = int(month_metadata)
                        if month_int == 10 and month_metadata_int == 10:
                            object_save = {
                                'mes_metadata': month_metadata,
                                'institution': item['establishment_identification'],
                                'numeral': item['numeral'],
                                'year': item['year'],
                                'mes': month,
                                'id': item['_id'],
                                'mensaje': '',
                                'tiene_publicacion_septiembre': 'Si'
                            }

                            object_find = TransparencyActive.objects.filter(
                                establishment__identification=item['establishment_identification'],
                                month=9,
                                numeral__name=item['numeral']
                            ).first()
                            if not object_find:
                                object_save['tiene_publicacion_septiembre'] = 'No'
                                copy = TransparencyActive.objects.filter(
                                    establishment__identification=item['establishment_identification'],
                                    month=10,
                                    numeral__name=item['numeral']
                                ).first()

                                if copy:
                                    # crear un nuevo registro a partir de copy
                                    max_date = datetime(
                                        year=copy.year, month=9, day=get_day_for_publish())
                                    max_date_aware = timezone.make_aware(
                                        max_date)
                                    obj = TransparencyActive.objects.create(
                                        establishment_id=copy.establishment_id,
                                        numeral_id=copy.numeral_id,
                                        month=9,
                                        year=copy.year,
                                        status=copy.status,
                                        published=copy.published,
                                        published_at=copy.published_at,
                                        max_date_to_publish=max_date_aware,
                                    )
                                    try:
                                        for file in copy.files.all():
                                            # abrir el archivo y copiarlo
                                            root = 'media/transparencia/' + \
                                                str(copy.establishment.identification) + '/' + \
                                                str(copy.numeral.name) + '/' + \
                                                str(copy.year) + '/' + \
                                                str(9)

                                            original_file_path = file.url_download.path
                                            root = os.path.join(
                                                root, file.description+'.csv')

                                            if not os.path.exists(root):

                                                shutil.copy(
                                                    original_file_path, root)

                                            new_file_pub = FilePublication.objects.create(
                                                name=file.name,
                                                description=file.description,
                                                url_download=root.replace(
                                                    'media/', ''),
                                                is_active=True,
                                                is_colab=False
                                            )

                                            obj.files.add(new_file_pub)
                                        lista_creada.append(object_save)
                                    except Exception as e:
                                        # [Errno 2] No such file or directory:
                                        if e.__str__().find('No such file or directory') != -1:
                                            # buscar en otros meses4
                                            obj.delete()
                                        else:
                                            if not obj.files.all().exists():
                                                obj.delete()
                                            object_save['mensaje'] = e.__str__()
                                            lista_creada.append(object_save)

                            else:

                                if not object_find.published:

                                    object_find.published = True
                                    object_find.published_at = object_find.created_at
                                    object_find.status = 'aproved'

                                for file in object_find.files.all():
                                    root = 'media/transparencia/' + \
                                        str(object_find.establishment.identification) + '/' + \
                                        str(object_find.numeral.name) + '/' + \
                                        str(object_find.year) + '/' + \
                                        str(9) + '/' + \
                                        file.description+".csv"
                                    # verificar que el archivo exista
                                    if os.path.exists(root):
                                        new_file_pub = FilePublication.objects.create(
                                            name=file.name,
                                            description=file.description,
                                            url_download=root.replace(
                                                'media/', ''),
                                            is_active=True,
                                            is_colab=False
                                        )

                                        object_find.files.filter(
                                            description=file.description).delete()

                                        object_find.files.add(new_file_pub)
                                    else:
                                        object_save['mensaje'] = 'No se encuentra el archivo ' + root

                                object_find.save()
                                lista_creada.append(object_save)

        except Exception as e:
            print(e)
        path = os.path.dirname(__file__)
        path = os.path.join(path, 'casos_septiembre.json')

        with open(path, 'w') as file:
            json.dump(lista_creada, file, indent=4)

    def fix_focal_september(self):
        focal = TransparencyFocal.objects.filter(
            month=10, year=2024)

        focal_sep = TransparencyFocal.objects.filter(
            month=9, year=2024)

        for x, i in enumerate(focal):
            existe_en_septiembre = focal_sep.filter(
                establishment__identification=i.establishment.identification,
                year=i.year
            ).exists()
            if not existe_en_septiembre and i.published_at and i.published_at.month == 10:
                # crea una copia
                max_date = datetime(year=i.year, month=9,
                                    day=get_day_for_publish())
                max_date_aware = timezone.make_aware(max_date)
                obj = TransparencyFocal.objects.create(
                    establishment_id=i.establishment_id,
                    month=9,
                    year=i.year,
                    status='aproved',
                    published=True,
                    published_at=i.created_at,
                    max_date_to_publish=max_date_aware,
                    numeral_id=i.numeral_id
                )
                i.published = False
                i.status = 'ingress'
                i.save()

                for file in i.files.all():
                    # abrir el archivo y copiarlo

                    parent = 'media/transparencia/' + \
                        str(i.establishment.identification) + '/' + \
                        str(i.year) + '/' + \
                        str(9) + \
                        '/Focalizada'

                    original_file_path = file.url_download.path

                    root = os.path.join(parent, file.description+'.csv')

                    if not os.path.exists(root):
                        os.makedirs(parent, exist_ok=True)
                        shutil.copy(original_file_path, root)

                    new_file_pub = FilePublication.objects.create(
                        name=file.name,
                        description=file.description,
                        url_download=root.replace('media/', ''),
                        is_active=True,
                        is_colab=False
                    )

                    obj.files.add(new_file_pub)

    def fix_colab_september(self):

        colab = TransparencyColab.objects.filter(
            month=10, year=2024)

        colab_sep = TransparencyColab.objects.filter(
            month=9, year=2024)
        for x, i in enumerate(colab):
            existe_en_septiembre = colab_sep.filter(
                establishment__identification=i.establishment.identification,
                year=i.year
            ).exists()
            if not existe_en_septiembre and i.published_at and i.published_at.month == 10:
                # crea una copia
                max_date = datetime(year=i.year, month=9,
                                    day=get_day_for_publish())
                max_date_aware = timezone.make_aware(max_date)
                obj = TransparencyColab.objects.create(
                    establishment_id=i.establishment_id,
                    month=9,
                    year=i.year,
                    status='aproved',
                    published=True,
                    published_at=i.created_at,
                    max_date_to_publish=max_date_aware,
                    numeral_id=i.numeral_id

                )
                i.published = False
                i.status = 'ingress'
                i.save()
                for file in i.files.all():
                    # abrir el archivo y copiarlo
                    parent = 'media/transparencia/' + \
                        str(i.establishment.identification) + '/' + \
                        str(i.year) + '/' + \
                        str(9) + \
                        '/Colaborativa'

                    original_file_path = file.url_download.path

                    root = os.path.join(parent, file.description+'.csv')

                    if not os.path.exists(root):
                        os.makedirs(parent, exist_ok=True)
                        shutil.copy(original_file_path, root)

                    new_file_pub = FilePublication.objects.create(
                        name=file.name,
                        description=file.description,
                        url_download=root.replace('media/', ''),
                        is_active=True,
                        is_colab=False
                    )

                    obj.files.add(new_file_pub)

    def fix_september(self):

        ta = TransparencyActive.objects.filter(
            month=9)
        for x, i in enumerate(ta):

            files = i.files.all()

            print("Procesando: {} de {} entidad {} con fecha {}".format(
                x, len(ta), i.establishment.identification, i.created_at))
            for file in files:

                path_like = i.establishment.identification + \
                    '/' + i.numeral.name + '/' + str(i.year) + '/9'

                if path_like not in file.url_download.url:

                    root = 'media/transparencia/' + path_like + '/' + file.description + '.csv'

                    if os.path.exists(root):
                        new_file_pub = FilePublication.objects.create(
                            name=file.name,
                            description=file.description,
                            url_download=root.replace('media/', ''),
                            is_active=True,
                            is_colab=False
                        )
                        i.files.filter(description=file.description).delete()
                        i.files.add(new_file_pub)
                    else:
                        print('No se encuentra el archivo ' + root)

    
    def fix_active_files(self):

        dir_ = os.path.dirname(__file__)
        dir_ = os.path.join(dir_, 'Results.json')
        est = EstablishmentExtended.objects.all()
        files = FilePublication.objects.all()

        with open(dir_, encoding='utf-8') as file:
            data = json.load(file)
            for item in data:
                establishment = est.filter(
                    identification=item['identification']).first()
                if establishment:

                    # "2024-10-07 09:42:05.607553-05
                    published_at = item['published_at']
                    if published_at == 'NULL':
                        published_at = item['created_at']
                    max_date = datetime(year=2024, month=9,
                                        day=get_day_for_publish())

                    
                    validation = TransparencyActive.objects.filter(
                        establishment_id=establishment.id,
                        month=9,
                        year=2024,
                        numeral_id=item['numeral_id']
                    ).first()
                    if not validation:
                        
                        
                    
                        focal = TransparencyActive.objects.create(
                            establishment_id=establishment.id,
                            month=9,
                            year=2024,
                            status='aproved',
                            published=True,
                            published_at=published_at,
                            numeral_id=item['numeral_id'],
                            max_date_to_publish=max_date
                        )

                        for file in item['archivos']:

                            if os.path.exists('media/'+file['url_download']):

                                obj_file = files.filter(
                                    url_download=file['url_download']).first()
                                if obj_file:
                                    focal.files.add(obj_file)

                                else:
                                    focal.delete()
                                    print(
                                        'No se encuentra el archivo en la base de datos' + file['url_download'])
                            else:
                                p = TransparencyActive.objects.filter(
                                    establishment_id=establishment.id,
                                    month=11,
                                    year=2024,
                                    numeral_id=item['numeral_id']
                                ).first()
                                if p:
                                    _copy = p.files.filter(
                                        description=file['description'])

                                    # crear una copia del archivo
                                    if _copy.exists():
                                        _copy = _copy.first()

                                        if os.path.exists(_copy.url_download.path):
                                            os.makedirs('media/transparencia/' + str(
                                                establishment.identification) + '/' + str(2024) + '/' + str(9), exist_ok=True)

                                            shutil.copy(_copy.url_download.path, 'media/transparencia/' + str(
                                                establishment.identification) + '/' + str(2024) + '/' + str(9) + '/' + file['description'] + '.csv')
                                            new_file_pub = FilePublication.objects.create(
                                                name=_copy.name,
                                                description=_copy.description,
                                                url_download=_copy.url_download.url.replace(
                                                    'media/', ''),
                                                is_active=True,
                                                is_colab=False
                                            )
                                            focal.files.add(new_file_pub)
                                        
    def fix_focal_files(self):

        dir_ = os.path.dirname(__file__)
        dir_ = os.path.join(dir_, 'Results.json')
        est = EstablishmentExtended.objects.all()
        files = FilePublication.objects.all()

        with open(dir_, encoding='utf-8') as file:
            data = json.load(file)
            for item in data:
                establishment = est.filter(
                    identification=item['identification']).first()
                if establishment:

                    # "2024-10-07 09:42:05.607553-05
                    published_at = item['published_at']
                    if published_at == 'NULL':
                        published_at = item['created_at']
                    max_date = datetime(year=2024, month=9,
                                        day=get_day_for_publish())

                    focal = TransparencyFocal.objects.create(
                        establishment_id=establishment.id,
                        month=9,
                        year=2024,
                        status='aproved',
                        published=True,
                        published_at=published_at,
                        numeral_id=item['numeral_id'],
                        max_date_to_publish=max_date
                    )

                    for file in item['archivos']:

                        if os.path.exists('media/'+file['url_download']):

                            obj_file = files.filter(
                                url_download=file['url_download']).first()
                            if obj_file:
                                focal.files.add(obj_file)

                            else:
                                focal.delete()
                                print(
                                    'No se encuentra el archivo en la base de datos' + file['url_download'])
                        else:
                            p = TransparencyFocal.objects.filter(
                                establishment_id=establishment.id,
                                month=11,
                                year=2024,
                                numeral_id=item['numeral_id']
                            ).first()
                            if p:
                                _copy = p.files.filter(
                                    description=file['description'])

                                # crear una copia del archivo
                                if _copy.exists():
                                    _copy = _copy.first()

                                    if os.path.exists(_copy.url_download.path):
                                        os.makedirs('media/transparencia/' + str(
                                            establishment.identification) + '/' + str(2024) + '/' + str(9), exist_ok=True)

                                        shutil.copy(_copy.url_download.path, 'media/transparencia/' + str(
                                            establishment.identification) + '/' + str(2024) + '/' + str(9) + '/' + file['description'] + '.csv')
                                        new_file_pub = FilePublication.objects.create(
                                            name=_copy.name,
                                            description=_copy.description,
                                            url_download=_copy.url_download.url.replace(
                                                'media/', ''),
                                            is_active=True,
                                            is_colab=False
                                        )
                                        focal.files.add(new_file_pub)

    def fix_presidencia(self):
        nu = TransparencyActive.objects.filter(
            establishment__identification='1160048360001',
            month=10,
            year=2024,

        )
        sep = TransparencyActive.objects.filter(
            establishment__identification='1160048360001',
            month=9,
            year=2024,
        )
        print(nu)

        for i in nu:
            exist = sep.filter(numeral_id=i.numeral_id).exists()
            if not exist:
                new = TransparencyActive.objects.create(
                    establishment_id=i.establishment_id,
                    month=9,
                    year=2024,
                    status='aproved',
                    published=True,
                    published_at=i.created_at,
                    numeral_id=i.numeral_id,
                    max_date_to_publish=i.max_date_to_publish)
                print('Creado '+ new.numeral.name)
                
                for file in i.files.all():
                    if os.path.exists(file.url_download.path):

                        # crear copia

                        new_file_pub = FilePublication.objects.create(
                            name=file.name,
                            description=file.description,
                            url_download=file.url_download.url.replace(
                                'media/', ''),
                            is_active=True,
                            is_colab=False
                        )
                        new.files.add(new_file_pub)
