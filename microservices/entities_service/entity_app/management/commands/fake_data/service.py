
from .ta.main import TransparencyActiveFakeData


class FakeDataService:
    def __init__(self):
        self.ta_service = TransparencyActiveFakeData()

    def generate_fake_ta(self):
        self.ta_service.create_fake_data()
