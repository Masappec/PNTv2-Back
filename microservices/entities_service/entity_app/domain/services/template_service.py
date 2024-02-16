from entity_app.ports.repositories.template_file_repository import TemplateFileRepository


class TemplateService:
    
    
    def __init__(self, template_repo:TemplateFileRepository):
        self.template_repo = template_repo
        
        
    
    
    def validate_file(self, template_id, file):
        return self.template_repo.validate_file(template_id, file)