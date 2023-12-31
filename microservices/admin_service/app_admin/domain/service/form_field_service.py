

from app_admin.ports.repositories.form_field_repository import FormFieldsRespository


class FormFieldsService:
    
    def __init__(self, form_fields_repository: FormFieldsRespository):
        self.form_fields_repository = form_fields_repository
        
        
    def get_form_fields_by_role_and_form_type(self, role: str, form_type: str):
        return self.form_fields_repository.get_form_fields_by_role_and_form_type(role, form_type)