from abc import ABC, abstractmethod

class FormFieldsRespository(ABC):
    

    
    @abstractmethod
    def get_form_fields_by_role_and_form_type(self, role: str, form_type: str):
        pass