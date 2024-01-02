

from app.ports.repositories.person_repository import PersonRepository
from app.adapters.serializer import RegisterSerializer
from rest_framework.serializers import Serializer

class PersonService:
    
    def __init__(self, person_repository: PersonRepository):
        """
        The constructor for the PersonService class.

        Args:
            person_repository (PersonRepository): The person_repository parameter is an instance of the
            PersonRepository class that will be used to retrieve,
            create, update, and delete person objects.
        """
        self.person_repository = person_repository
        
        
    def get_person(self, person_id: int):
        """
        Get a person by id.

        Args:
            person_id (int): The id of the person to retrieve.

        Returns:
            Person: The person object.
        """
        return self.person_repository.get_person(person_id)
    
    def get_person_by_email(self, email: str):
        """
        Get a person by email.

        Args:
            email (str): The email of the person to retrieve.

        Returns:
            Person: The person object.
        """
        return self.person_repository.get_person_by_email(email)
    
    
    def get_person_by_userid(self, user_id: str):
        """
        Get a person by userid.

        Args:
            user_id (str): The userid of the person to retrieve.

        Returns:
            Person: The person object.
        """
        return self.person_repository.get_person_by_userid(user_id)
    
    def create_person(self, person: RegisterSerializer):
        """
        The function creates a person object using the provided dictionary of person data.

        Args:
            person (dict): The `person` parameter is a dictionary that

        Returns:
            Person: The create_person method is returning an instance of the
                  Person model that has been created
                  with the provided person dictionary.
        """
        data = {
            'first_name': person.validated_data['first_name'],
            'last_name': person.validated_data['last_name'],
            'identification': person.validated_data['identification'],
            'phone': person.validated_data['phone'],
            'address': person.validated_data['city'],
            'city': person.validated_data['city'],
            'race': person.validated_data['race'],
            'disability': person.validated_data['disability'] if 'disability' in person.validated_data else False,
            'age_range': person.validated_data['age_range'],
            'province': person.validated_data['province'],
            'accept_terms': person.validated_data['accept_terms'] if 'accept_terms' in person.validated_data else False,
        }
        if data['accept_terms'] == False:
            raise Exception('Debe aceptar los terminos y condiciones')
        return self.person_repository.create_person(data)
    
    def assign_user(self, person_id: int, user_id: int):
        """
        Assign a user to a person.

        Args:
            person_id (int): The id of the person to assign the user to.
            user_id (int): The id of the user to assign to the person.

        Returns:
            Person: The person object.
        """
        return self.person_repository.assign_user(person_id, user_id)
        
        
    def delete_permament_person(self, person_id: int):
        """
        Delete a person.

        Args:
            person_id (int): The id of the person to delete.

        Returns:
            Person: The person object.
        """
        return self.person_repository.delete_permament_person(person_id)
    
    
    def update_person_by_user_id(self, user_id: int, person: Serializer):
        """
        Update a person.

        Args:
            user_id (int): The id of the user to update.
            person (dict): The person data to update.

        Returns:
            Person: The person object.
        """
        data = {
            'first_name': person.validated_data['first_name'],
            'last_name': person.validated_data['last_name'],
            'identification': person.validated_data['identification'],
            'phone': person.validated_data['phone'],
            'address': person.validated_data['city'],
            'city': person.validated_data['city'],
            'race': person.validated_data['race'],
            'disability': person.validated_data['disability'] if 'disability' in person.validated_data else False,
            'age_range': person.validated_data['age_range'],
            'province': person.validated_data['province'],
        }
        return self.person_repository.update_person_by_user_id(user_id, data)