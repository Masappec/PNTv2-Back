

from app.ports.repositories.person_repository import PersonRepository
from app.adapters.serializer import RegisterSerializer


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
            'address': person.validated_data['address'],
            'city': person.validated_data['city'],
            'country': person.validated_data['country'],
            'province': person.validated_data['province'],
            'type_person': person.validated_data['type_person'],
        }
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