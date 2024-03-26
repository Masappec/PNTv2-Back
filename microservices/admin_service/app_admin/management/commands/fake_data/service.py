from faker import Faker

from .establishment.main import EstablishmentFakeData


class FakeDataService:
    def __init__(self):
        self.establisment_service = EstablishmentFakeData

    def generate_fake_establishment(self, quantity: int):
        self.establisment_service().generate_fake_data(quantity)
