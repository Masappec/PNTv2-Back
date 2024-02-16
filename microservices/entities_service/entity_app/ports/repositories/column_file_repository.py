
from abc import ABC, abstractmethod

class ColumnFileRepository(ABC):
    
    def get_all(self):
        pass
    
    
    def get(self, id):
        pass
    
    
    def get_by_template(self, template_id):
        pass