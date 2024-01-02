


from app_admin.domain.models import Establishment


class LawEnforcementService:
    '''   @abstractmethod
    def get_law_enforcement(self, law_enforcement_id: int):
        pass
    @abstractmethod
    
    def create_law_enforcement(self, law_enforcement: dict):
        pass
    
    @abstractmethod
    
    def assign_establishment_to_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        pass
    @abstractmethod
   
    def remove_establishment_to_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        pass
    @abstractmethod
    
    def update_law_enforcement(self, law_enforcement_id: int, law_enforcement: dict):
        pass
    @abstractmethod
    
    def delete_law_enforcement(self, law_enforcement_id: int):
        pass
    @abstractmethod
    
    def get_all_law_enforcement(self):
        pass'''
        
    def __init__(self, law_enforcement_repository):
        self.law_enforcement_repository = law_enforcement_repository
        
        
    def get_law_enforcement(self, law_enforcement_id: int):
        try:
            return self.law_enforcement_repository.get_law_enforcement(law_enforcement_id)
        except Exception as e:
            raise ValueError("Error al obtener la ley de cumplimiento: "+str(e))
        
    def create_law_enforcement(self, law_enforcement: dict):
        try:
            data = {
                'highest_committe': law_enforcement['highest_committe'],
                'first_name_committe': law_enforcement['first_name_committe'],
                'last_name_committe': law_enforcement['last_name_committe'],
                'job_committe': law_enforcement['job_committe'],
                'email_committe': law_enforcement['email_committe'],
            }
            return self.law_enforcement_repository.create_law_enforcement(data)
        except Exception as e:
            raise ValueError("Error al crear la ley de cumplimiento: "+str(e))
        
        
    def assign_establishment_to_law_enforcement(self, law_enforcement_id: int, establishment:Establishment):
        try:
            return self.law_enforcement_repository.assign_establishment_to_law_enforcement(law_enforcement_id, establishment)
        except Exception as e:
            raise ValueError("Error al asignar el establecimiento a la ley de cumplimiento: "+str(e))
        
        
    def remove_establishment_to_law_enforcement(self, law_enforcement_id: int, establishment_id: int):
        try:
            return self.law_enforcement_repository.remove_establishment_to_law_enforcement(law_enforcement_id, establishment_id)
        except Exception as e:
            raise ValueError("Error al remover el establecimiento a la ley de cumplimiento: "+str(e))
        
        
    def update_law_enforcement(self, law_enforcement_id: int, law_enforcement: dict):
        
        try:
            return self.law_enforcement_repository.update_law_enforcement(law_enforcement_id, law_enforcement)
        except Exception as e:
            raise ValueError("Error al actualizar la ley de cumplimiento: "+str(e))
        
        
    def delete_law_enforcement(self, law_enforcement_id: int):
        
        try:
            return self.law_enforcement_repository.delete_law_enforcement(law_enforcement_id)
        except Exception as e:
            raise ValueError("Error al eliminar la ley de cumplimiento: "+str(e))
        
    def get_all_law_enforcement(self):
        try:
            return self.law_enforcement_repository.get_all_law_enforcement()
        except Exception as e:
            raise ValueError("Error al obtener todas las leyes de cumplimiento: "+str(e))
        
        
    def get_law_enforcement_by_establishment(self, establishment_id: int):
        try:
            return self.law_enforcement_repository.get_law_enforcement_by_establishment(establishment_id)
        except Exception as e:
            raise ValueError("Error al obtener la ley de cumplimiento por establecimiento: "+str(e))
        
    def update_law_enforcement_by_establishment_id(self, establishment_id: int, law_enforcement: dict):
        try:
            data = {
                'highest_committe': law_enforcement['highest_committe'],
                'first_name_committe': law_enforcement['first_name_committe'],
                'last_name_committe': law_enforcement['last_name_committe'],
                'job_committe': law_enforcement['job_committe'],
                'email_committe': law_enforcement['email_committe'],
            }
            return self.law_enforcement_repository.update_law_enforcement_by_establishment_id(establishment_id, data)
        except Exception as e:
            raise ValueError("Error al actualizar la ley de cumplimiento por establecimiento: "+str(e))