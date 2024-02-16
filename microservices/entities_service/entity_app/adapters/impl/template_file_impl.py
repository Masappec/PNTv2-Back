

from entity_app.ports.repositories.template_file_repository import TemplateFileRepository
from entity_app.domain.models.transparency_active import TemplateFile
from django.core.files.uploadedfile import UploadedFile
from pandas import read_csv

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
            
        except TemplateFile.DoesNotExist:
            
            raise ValueError('El template no existe')
        
        
        if file.name.endswith('.csv') or file.name.endswith('.xls') or file.name.endswith('.xlsx'):
            #liberar el archivo
            
            csv = read_csv(file,encoding='utf-8')
            
            
            headers = csv.columns
            
            if not all([header in template.columns.all().values_list('name', flat=True) for header in headers]):
                raise ValueError('El archivo no tiene las columnas requeridas')
            
            
            
            for header in headers:
                if csv[header].isnull().values.any():
                    raise ValueError('El archivo contiene valores nulos')
                
                
                for value in csv[header]:
                    
                    if type(value) != template.columns.get(name=header).type:
                        raise ValueError('El archivo contiene valores no validos')
                
                
            if template.max_inserts and len(csv)-1 > template.max_inserts:
                raise ValueError('El archivo contiene mas registros de los permitidos')
            
            
            return csv

        
        raise ValueError('El archivo no es del tipo permitido')