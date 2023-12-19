from django.test import TestCase
from django.test.client import FakePayload
from rest_framework.test import APIClient
from app.domain.models import User
from faker import Faker as fk


the_fake = fk()


class TestRegister(TestCase):
    """
    This class contains test cases for the authentication functionality.
    """

    def __init__(self, methodName: str = "runTest"):
        super().__init__(methodName=methodName)

    def setUp(self):
        self.api = APIClient()

    def test_register_success(self):
        
        data = {
            'username': the_fake.profile()['username'],
            'password': the_fake.password(),
            'email': the_fake.profile()['mail'],
            'first_name': the_fake.profile()['name'],
            'last_name': the_fake.profile()['name'],
        }
        request = self.api.post(
            '/auth/register/', data)
        print("=========TEST REGISTER SUCCESS===========")
        print(request.data)
        print("=====================================")

        assert request.status_code == 201



    def test_register_fail(self):
        data = {
            'username': the_fake.profile()['username'],
            'password': the_fake.password(),
            'first_name': the_fake.profile()['name'],
            'last_name': the_fake.profile()['name'],
        }
        request = self.api.post('/auth/register/', data)
        print("==========TEST REGISTER FAIL=============")
        print(request.data)
        print("=====================================")
        
        assert request.status_code == 400
        
        
    def test_register_username_already_exists(self):
        username = the_fake.profile()['username']
        password = the_fake.password()
        email = the_fake.profile()['mail']
        first_name = the_fake.profile()['name']
        last_name = the_fake.profile()['name']
        
        User.objects.create_user(username=username, password=password, email=email, first_name=first_name, last_name=last_name)
        data = {
            'username': username,
            'password': password,
            'email': email,
            'first_name': first_name,
            'last_name': last_name,
        }
        request = self.api.post('/auth/register/', data)
        print("==========TEST REGISTER USERNAME ALREADY EXISTS=============")
        print(request.data)
        print("=====================================")
        
        assert request.status_code == 400
        
        
    def test_register_email_already_exists(self):
        username = the_fake.profile()['username']
        password = the_fake.password()
        email = the_fake.profile()['mail']
        first_name = the_fake.profile()['name']
        last_name = the_fake.profile()['name']
        
        User.objects.create_user(username=username, password=password, email=email, first_name=first_name, last_name=last_name)
        data = {
            'username': the_fake.profile()['username'],
            'password': the_fake.password(),
            'email': email, 
            'first_name': the_fake.profile()['name'],
            'last_name': the_fake.profile()['name'],
        }
        request = self.api.post('/auth/register/', data)
        print("==========TEST REGISTER EMAIL ALREADY EXISTS=============")
        print(request.data)
        print("=====================================")
        
        assert request.status_code == 400
        
        
    def test_register_username_not_valid(self):
        data = {
            'username': 5555555555555,
            'password': the_fake.password(),
            'email': 5555555,
            'first_name': the_fake.profile()['name'],
            'last_name': the_fake.profile()['name'],
        }
        request = self.api.post('/auth/register/', data)
        print("==========TEST REGISTER USERNAME NOT VALID=============")
        print(request.data)
        print("=====================================")
        
        assert request.status_code == 400
        
        
    def test_register_email_not_valid(self):
        data = {
            'username': the_fake.profile()['username'],
            'password': the_fake.password(),
            'email': 'admin',
            'first_name': the_fake.profile()['name'],
            'last_name': the_fake.profile()['name'],
        }
        request = self.api.post('/auth/register/', data)
        print("==========TEST REGISTER EMAIL NOT VALID=============")
        print(request.data)
        print("=====================================")
        
        assert request.status_code == 400
        
        
    def test_register_password_not_valid(self):
        
        data = {
            'username': the_fake.profile()['username'],
            'password': 'admin',
            'email': the_fake.profile()['mail'],
            'first_name': the_fake.profile()['name'],
            'last_name': the_fake.profile()['name'],
        }
        request = self.api.post('/auth/register/', data)
        print("==========TEST REGISTER PASSWORD NOT VALID=============")
        print(request.data)
        print("=====================================")
        
        assert request.status_code == 400