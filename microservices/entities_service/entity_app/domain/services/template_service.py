from entity_app.ports.repositories.template_file_repository import TemplateFileRepository
from entity_app.domain.models import TemplateFile
from typing import List


class TemplateService:

    def __init__(self, template_repo: TemplateFileRepository):
        self.template_repo = template_repo

    def validate_file(self, template_id, file):
        return self.template_repo.validate_file(template_id, file)

    def get_templates_by_numeral(self, numeral_id) -> List[TemplateFile]:
        return self.template_repo.get_by_numeral(numeral_id)
