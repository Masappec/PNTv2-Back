
from abc import ABC, abstractmethod


class AttachmentRepository(ABC):
    
    @abstractmethod
    def save(self, attachment):
        pass
    
    
    @abstractmethod
    def get(self, attachment_id):
        pass
    
    @abstractmethod
    def get_by_entity_id(self, entity_id):
        pass
    
    
    @abstractmethod
    def delete(self, attachment_id):
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id):
        pass
    