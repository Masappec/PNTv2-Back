
from app_admin.domain.service.establishment_service import EstablishmentService
from app_admin.domain.service.access_information_service import AccessInformationService
from app_admin.domain.service.law_enforcement_service import LawEnforcementService
from app_admin.adapters.impl.establishment_impl import EstablishmentRepositoryImpl
from app_admin.adapters.impl.access_information_impl import AccessInformationImpl
from app_admin.adapters.impl.law_enforcement_impl import LawEnforcementImpl
from faker import Faker
from app_admin.utils.function import generate_image_with_text, progress_bar
from django.conf import settings
from django.core.files import File

import os


class EstablishmentFakeData:

    def __init__(self) -> None:
        self.establishment_service = EstablishmentService(
            EstablishmentRepositoryImpl())
        self.access_info = AccessInformationService(AccessInformationImpl())
        self.law_enforcement = LawEnforcementService(LawEnforcementImpl())
        self.fake = Faker()

    def generate_fake_data(self, quantity: int):
        file = generate_image_with_text(400, 200, self.fake.text())

        for _ in range(quantity):
            print(progress_bar(_, quantity), end='\r', flush=True)
            establishment = self.establishment_service.create_establishment(
                {
                    'name': self.fake.first_name(),
                    'abbreviation': self.fake.first_name(),
                    'highest_authority': self.fake.first_name(),
                    'first_name_authority': self.fake.first_name(),
                    'last_name_authority': self.fake.last_name(),
                    'job_authority': self.fake.job(),
                    'email_authority': self.fake.email(),
                    'extra_numerals': []
                },
                file
            )

            access = self.access_info.create_access_information({
                'email_accesstoinformation': self.fake.email()
            })
            law = self.law_enforcement.create_law_enforcement({
                'highest_committe': self.fake.first_name(),
                'first_name_committe': self.fake.first_name(),
                'last_name_committe': self.fake.last_name(),
                'job_committe': self.fake.job(),
                'email_committe': self.fake.email()
            })

            self.access_info.assign_establishment_to_access_information(
                access.id, establishment)
            self.law_enforcement.assign_establishment_to_law_enforcement(
                law.id, establishment)
