

from entity_app.ports.repositories.template_file_repository import TemplateFileRepository
from entity_app.domain.models.transparency_active import TemplateFile
from django.core.files.uploadedfile import UploadedFile
from pandas import read_csv, read_excel
from entity_app.utils.functions import validate_type
from django.core.exceptions import ObjectDoesNotExist

class TemplateFileImpl(TemplateFileRepository):
    
    
    def get_all(self):
        return TemplateFile.objects.all()
    
    
    def get(self, id):
        return TemplateFile.objects.get(id=id)
    
    
    def get_by_numeral(self, numeral_id):
        return TemplateFile.objects.filter(numerals__id=numeral_id)
    
    
    
    def validate_file(self, template_id, file:UploadedFile):
        
        try:
        
            template = TemplateFile.objects.get(id=template_id)
            
        except ObjectDoesNotExist:
            
            raise ValueError('El template no existe')
        except Exception as e :
            raise ValueError('El template no existe')
        
        
        
        csv = None
        templates_headers = [column.name for column in template.columns.all()]

        if not file.name.endswith('.csv') and not file.name.endswith('.xls') and not file.name.endswith('.xlsx'):
            raise ValueError('El archivo no es del tipo permitido')
        if file.name.endswith('.csv'):
            csv = read_csv(file,encoding='utf-8', delimiter=';')
            
        if file.name.endswith('.xls') or file.name.endswith('.xlsx'):
            
            if template.vertical_template:
                csv = read_excel(file, header=None,names=[ 'A', 'B'])
            else:
                csv = read_excel(file)
        

        
       
        headers = csv.columns.to_list()
        if template.vertical_template:
            headers = csv.get('A').to_list()
            csv = csv.transpose()
            
            print(csv )
            
            
            
        
        print(templates_headers)
        if set(headers) != set(templates_headers):
            raise ValueError('El archivo no contiene las columnas necesarias')
        
        
        
        for header in headers:
            if csv[header].isnull().values.any():
                raise ValueError('El archivo contiene valores nulos')
            
            
            for value in csv[header]:
                
                if validate_type(type(value),template.columns.get(name=header).type):
                    raise ValueError('El archivo contiene valores no validos')
            
        
        if template.max_inserts and len(csv)-1 > template.max_inserts:
            raise ValueError('El archivo contiene mas registros de los permitidos')
        
        
        return csv
