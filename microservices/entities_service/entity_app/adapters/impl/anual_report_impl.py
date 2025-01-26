from typing import List, Optional
from entity_app.ports.repositories.anual_report_reposity import AnualReportReposity
from entity_app.domain.models.anual_report import AnualReport, IndexInformationClassified, SolicityInforAnualReport


class AnualReportImpl(AnualReportReposity):
    
    def get(self, establishment_id: int, year: int):
        return AnualReport.objects.filter(establishment_id=establishment_id, year=year).first()

    def get_all(self):
        return AnualReport.objects.all()

    def add(self, 
        establishment_id: int,
        year: int,
        month: int,
        have_public_records: bool,
        norme_archive_utility: str,
        comment_aclaration: str,
        total_saip: int,
        did_you_entity_receive: bool,
        total_saip_in_portal: int,
        total_saip_no_portal: int,
        description_rason_no_portal: str,
        total_no_registered: int,
        comment_aclaration_no_registered: str,
        reserve_information: bool,
        number_of_reserves: int,
        number_of_confidential: int,
        number_of_secret: int,
        number_of_secretism: int,
        # IDs of IndexInformationClassified
        information_classified,
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
        description_activities: str,
            solicity_infor_anual_report,
            have_responded_solicities_no_portal
    ):
        
        created = AnualReport.objects.create(
            establishment_id=establishment_id,
            year=year,
            month=month,
            have_public_records=have_public_records,
            norme_archive_utility=norme_archive_utility,
            comment_aclaration=comment_aclaration,
            total_saip=total_saip,
            did_you_entity_receive=did_you_entity_receive,
            total_saip_in_portal=total_saip_in_portal,
            total_saip_no_portal=total_saip_no_portal,
            description_rason_no_portal=description_rason_no_portal,
            total_no_registered=total_no_registered,
            comment_aclaration_no_registered=comment_aclaration_no_registered,
            reserve_information=reserve_information,
            number_of_reserves=number_of_reserves,
            number_of_confidential=number_of_confidential,
            number_of_secret=number_of_secret,
            number_of_secretism=number_of_secretism,
            have_quality_problems=have_quality_problems,
            total_quality_problems=total_quality_problems,
            description_quality_problems=description_quality_problems,
            have_sanctions=have_sanctions,
            total_organic_law_public_service=total_organic_law_public_service,
            description_organic_law_public_service=description_organic_law_public_service,
            total_organic_law_contraloria=total_organic_law_contraloria,
            description_organic_law_contraloria=description_organic_law_contraloria,
            total_organic_law_national_system=total_organic_law_national_system,
            description_organic_law_national_system=description_organic_law_national_system,
            total_organic_law_citizen_participation=total_organic_law_citizen_participation,
            description_organic_law_citizen_participation=description_organic_law_citizen_participation,
            implemented_programs=implemented_programs,
            total_programs=total_programs,
            description_programs=description_programs,
            have_activities=have_activities,
            total_activities=total_activities,
            description_activities=description_activities,
            have_responded_solicities_no_portal=have_responded_solicities_no_portal
        )


        # Relación ManyToMany para información clasificada
        if information_classified:
            for info in information_classified:
                obj = IndexInformationClassified.objects.create(**info,anual_report_id=created.id)
        if solicity_infor_anual_report:
            for info in solicity_infor_anual_report:
                obj = SolicityInforAnualReport.objects.create(**info, anual_report_id=created.id)
        return AnualReport.objects.filter(id=created.id).first()
        

    def update(self, id:int, establishment_id: int,
               year: int,
               month: int,
               have_public_records: bool,
               norme_archive_utility: str,
               comment_aclaration: str,
               have_annual_report: bool,
               total_saip: int,
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
               description_activities: str,
               have_responded_solicities_no_portal
               ):
        
       return AnualReport.objects.filter(id=id).update(
            establishment_id=establishment_id,
            year=year,
            month=month,
            have_public_records=have_public_records,
            norme_archive_utility=norme_archive_utility,
            comment_aclaration=comment_aclaration,
            have_annual_report=have_annual_report,
           total=total_saip,
            did_you_entity_receive=did_you_entity_receive,
            desription=desription,
            total_no_registered=total_no_registered,
            comment_aclaration_no_registered=comment_aclaration_no_registered,
            reserve_information=reserve_information,
            number_of_reserves=number_of_reserves,
            number_of_confidential=number_of_confidential,
            number_of_secret=number_of_secret,
            number_of_secretism=number_of_secretism,
            have_quality_problems=have_quality_problems,
            total_quality_problems=total_quality_problems,
            description_quality_problems=description_quality_problems,
            have_sanctions=have_sanctions,
            total_organic_law_public_service=total_organic_law_public_service,
            description_organic_law_public_service=description_organic_law_public_service,
            total_organic_law_contraloria=total_organic_law_contraloria,
            description_organic_law_contraloria=description_organic_law_contraloria,
            total_organic_law_national_system=total_organic_law_national_system,
            description_organic_law_national_system=description_organic_law_national_system,
            total_organic_law_citizen_participation=total_organic_law_citizen_participation,
            description_organic_law_citizen_participation=description_organic_law_citizen_participation,
            implemented_programs=implemented_programs,
            total_programs=total_programs,
            description_programs=description_programs,
            have_activities=have_activities,
            total_activities=total_activities,
            description_activities=description_activities,
            have_responded_solicities_no_portal=have_responded_solicities_no_portal
        )


