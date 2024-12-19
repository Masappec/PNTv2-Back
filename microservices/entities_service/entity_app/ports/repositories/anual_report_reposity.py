from abc import ABC, abstractmethod
from entity_app.domain.models.anual_report import AnualReport
from django.db.models.query import QuerySet

class AnualReportReposity(ABC):
    @abstractmethod
    def get(self, 
            establishment_id: int,
            year: int,
            month: int
            ) -> AnualReport:
        pass

    @abstractmethod
    def get_all(self) -> QuerySet[AnualReport]:
        pass

    @abstractmethod
    def add(self,
            establishment_id: int,
            year: int,
            month: int,
            have_public_records: bool,
            norme_archive_utility: str,
            comment_aclaration: str,
            have_annual_report: bool,
            total: int,
            did_you_entity_receive: bool,
            desription: str,
            total_no_registered: int,
            comment_aclaration_no_registered: str,
            reserve_information: bool,
            number_of_reserves: int,
            number_of_confidential: int,
            number_of_secret: int,
            number_of_secretism: int,
            have_quality_problems: bool,
            total_quality_problems: int,
            description_quality_problems: str,
            have_sanctions: bool,
            total_organic_law_public_service: int,
            description_organic_law_public_service: str,
            total_organic_law_contraloria: int,
            description_organic_law_contraloria: str,
            total_organic_law_national_system: int,
            description_organic_law_national_system: str,
            total_organic_law_citizen_participation: int,
            description_organic_law_citizen_participation: str,
            implemented_programs: bool,
            total_programs: int,
            description_programs: str,
            have_activities: bool,
            total_activities: int,
            description_activities: str) -> AnualReport:
        pass

    @abstractmethod
    def update(self, id: int, establishment_id: int,
               year: int,
               month: int,
               have_public_records: bool,
               norme_archive_utility: str,
               comment_aclaration: str,
               have_annual_report: bool,
               total: int,
               did_you_entity_receive: bool,
               desription: str,
               total_no_registered: int,
               comment_aclaration_no_registered: str,
               reserve_information: bool,
               number_of_reserves: int,
               number_of_confidential: int,
               number_of_secret: int,
               number_of_secretism: int,
               have_quality_problems: bool,
               total_quality_problems: int,
               description_quality_problems: str,
               have_sanctions: bool,
               total_organic_law_public_service: int,
               description_organic_law_public_service: str,
               total_organic_law_contraloria: int,
               description_organic_law_contraloria: str,
               total_organic_law_national_system: int,
               description_organic_law_national_system: str,
               total_organic_law_citizen_participation: int,
               description_organic_law_citizen_participation: str,
               implemented_programs: bool,
               total_programs: int,
               description_programs: str,
               have_activities: bool,
               total_activities: int,
               description_activities: str) -> AnualReport:
        pass
