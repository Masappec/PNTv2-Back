from abc import ABC, abstractmethod

class PedagogyArea(ABC):
    
    
    @abstractmethod
    def get_area(self):
        pass
    
    
    @abstractmethod
    def update_area(self):
        pass