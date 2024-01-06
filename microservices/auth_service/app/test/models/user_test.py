




from django.test import TestCase
from app.domain.models import User
from faker import Faker as fk

from app.adapters.serializer import RegisterSerializer

the_fake = fk()
class UserModelTest(TestCase):
    
    
    
    def test_register_citizen_user(self):
       
        try:
            data = {
                'username': the_fake.profile()['mail'],
                'email': the_fake.profile()['mail'],
                'password': the_fake.password(),
                'first_name': the_fake.profile()['name'],
                'last_name': the_fake.profile()['name'],
                'identification': the_fake.profile()['ssn'],
                'phone': '1234567890',
                'address': the_fake.profile()['address'],
                'city': the_fake.profile()['address'],
                'race': the_fake.profile()['name'],
                'disability': False,
                'age_range': the_fake.profile()['birthdate'],
                'province': the_fake.profile()['address'],
                'accept_terms': False,
            }
            
            User.register_citizen_user(**data)
        except Exception as e:
            assert  e == 'Debe aceptar los términos y condiciones'
        
        
