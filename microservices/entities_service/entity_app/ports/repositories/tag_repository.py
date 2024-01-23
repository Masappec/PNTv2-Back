from abc import ABC, abstractmethod


class TagRepository(ABC):
    
    
    @abstractmethod
    def find_by_name(self, name: str):
        pass
    
    
    @abstractmethod
    def find_all(self):
        pass
    
    
    @abstractmethod
    def save(self, name: str):
        pass
    
    
    @abstractmethod
    def delete(self, id: int):
        pass

    
    