from abc import ABC, abstractmethod


class UserEstablishmentRepository(ABC):
    
    @abstractmethod
    def assign_user(self, user_id: int, establishment_id: int):
        pass
    
    
    @abstractmethod
    def get_user_by_establishment(self, establishment_id: int):
        pass
    
    
    @abstractmethod
    def get_establishment_by_user(self, user_id: int):
        pass
    
    
    @abstractmethod
    def remove_user(self, user_id: int, establishment_id: int):
        pass
    
    
    @abstractmethod
    def remove_all_users(self, establishment_id: int):
        pass