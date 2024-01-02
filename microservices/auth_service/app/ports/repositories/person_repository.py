from abc import ABC, abstractmethod


class PersonRepository(ABC):
    
    @abstractmethod
    def get_person(self, person_id: int):
        pass
    
    
    @abstractmethod
    def get_person_by_email(self, email: str):
        pass
    
    @abstractmethod
    def get_person_by_userid(self, user_id: str):
        pass
    
    @abstractmethod
    def create_person(self, person: dict):
        pass
    
    
    @abstractmethod
    def update_person(self, person_id: int, person: dict):
        pass
    
    @abstractmethod
    def assign_user(self, person_id: int, user_id: int):
        pass
        
        
    @abstractmethod
    def delete_person(self, person_id: int):
        pass
    
    @abstractmethod
    def get_persons(self):
        pass
    
    def delete_permament_person(self, person_id: int):
        pass
    

    @abstractmethod
    def update_person_by_user_id(self, user_id: int, person: dict):
        pass