

from app.ports.repositories.person_repository import PersonRepository
from app.domain.models import Person


class PersonRepositoryImpl(PersonRepository):

    def get_person(self, person_id: int):
        return Person.objects.get(pk=person_id)

    def get_person_by_email(self, email: str):
        return Person.objects.get(user__email=email)
    
    def get_person_by_userid(self, user_id: str):
        return Person.objects.get(user_id=user_id)
    
    def create_person(self, person: dict):
        return Person.objects.create(**person)
    
    def update_person(self, person_id: int, person: dict):
        return Person.objects.filter(pk=person_id).update(**person)
    
    def assign_user(self, person_id: int, user_id: int):
        return Person.objects.filter(pk=person_id).update(user_id=user_id)
    
    def delete_person(self, person_id: int):
        return Person.objects.filter(pk=person_id).delete()
    
    def get_persons(self):
        return Person.objects.all()


    def delete_permament_person(self, person_id: int):
        return Person.objects.filter(pk=person_id).delete()
    
    def update_person_by_user_id(self, user_id: int, person: dict):
        person_result = Person.objects.filter(user_id=user_id)
        if person_result.count()>0:
            
            person_result.update(**person)
        else:
            person_result = Person.objects.create(user_id=user_id,**person)
            return person_result
        return person_result.first()
        
        