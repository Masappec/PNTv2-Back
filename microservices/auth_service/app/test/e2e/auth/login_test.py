from django.test import TestCase
from django.test.client import FakePayload
from rest_framework.test import APIClient
from app.domain.models import User
from faker import Faker as fk


the_fake = fk()

class TestAuth(TestCase):
    """
    This class contains test cases for the authentication functionality.
    """

    def __init__(self, methodName: str = "runTest"):
        super().__init__(methodName=methodName)

    def setUp(self):
        self.api = APIClient()

    def test_login_success(self):
        password = the_fake.password()
        user = User.objects.create_user(username=the_fake.profile()['username'], password=password)
        request = self.api.post(
            '/auth/login/', {'username': user.username, 'password': password})
        print("=========TEST LOGIN SUCCESS===========")
        print(request.data)
        print("=====================================")

        assert request.status_code == 200 and 'access' in request.data and 'refresh' in request.data

    def test_login_fail(self):

        User.objects.create_user(username=the_fake.profile()['username'], password=the_fake.password())
        request = self.api.post(
            '/auth/login/', {'username': 'admin', 'password': 'admin1'})
        print("==========TEST LOGIN FAIL=============")
        print(request.data)
        print("=====================================")

        assert request.status_code == 401

    def test_login_user_not_found(self):
        
        username = the_fake.profile()['username']
        password = the_fake.password()
        
        User.objects.create_user(username=username, password=password)
        request = self.api.post(
            '/auth/login/', {'username': the_fake.profile()['username'], 'password': password})
        print("========TEST LOGIN USER NOT FOUND=======")
        print(request.data)
        print("=====================================")

        assert request.status_code == 401

    def test_login_user_not_active(self):
        username = the_fake.profile()['username']
        password = the_fake.password()

        User.objects.create_user(username=username, password=password, is_active=False)

        request = self.api.post(
            '/auth/login/', {'username': username, 'password': password})
        print("========TEST LOGIN USER NOT ACTIVE=======")

        print(request.data)
        print("=====================================")

        assert request.status_code == 401

    def test_login_user_not_superuser(self):

        
        username = the_fake.profile()['username']
        password = the_fake.password()
        
        User.objects.create_user(username=username, password=password)
        request = self.api.post(
            '/auth/login/', {'username': username, 'password': password})
        print("========TEST LOGIN USER NOT SUPERUSER=======")

        print(request.data)
        print("=====================================")

        assert request.status_code == 200
        
        
    def test_login_user_not_valid_data(self):
        request = self.api.post(
            '/auth/login/', {'username': 5555, 'password': the_fake.password()})
        print("========TEST LOGIN USER NOT VALID DATA=======")

        print(request.data)
        print("=====================================")

        assert request.status_code == 401
