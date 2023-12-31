

from app_admin.ports.repositories.form_field_repository import FormFieldsRespository
from app_admin.domain.models import FormFields


class FormFieldsImpl(FormFieldsRespository):
    
    
    def get_form_fields_by_role_and_form_type(self, role: str, form_type: str):
        return FormFields.objects.filter(role=role, form_type=form_type).order_by('order')
    