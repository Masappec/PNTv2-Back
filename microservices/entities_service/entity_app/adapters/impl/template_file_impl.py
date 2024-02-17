

from entity_app.ports.repositories.template_file_repository import TemplateFileRepository
from entity_app.domain.models.transparency_active import TemplateFile
from django.core.files.uploadedfile import UploadedFile
from pandas import read_csv
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
        
        
        if file.name.endswith('.csv') or file.name.endswith('.xls') or file.name.endswith('.xlsx'):
            #liberar el archivo
            
            csv = read_csv(file,encoding='utf-8', delimiter=';')
            
            
            headers = csv.columns.to_list()
            templates_headers = [column.name for column in template.columns.all()]
            
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

        
        raise ValueError('El archivo no es del tipo permitido')