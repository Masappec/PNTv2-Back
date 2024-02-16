from entity_app.ports.repositories.column_file_repository import ColumnFileRepository
from entity_app.domain.models.transparency_active import ColumnFile

class ColumnFileImpl(ColumnFileRepository):
    
    
    def get_all(self):
        return ColumnFile.objects.all()
    
    
    def get(self, id):
        return ColumnFile.objects.get(id=id)
    
    
    def get_by_template(self, template_id):
        return ColumnFile.objects.filter(template_id=template_id)