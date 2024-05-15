from app_admin.adapters.impl.establishment_impl import EstablishmentRepositoryImpl
from app_admin.domain.service.establishment_service import EstablishmentService
from app_admin.domain.service.access_information_service import AccessInformationService
from app_admin.domain.service.law_enforcement_service import LawEnforcementService
from app_admin.adapters.impl.access_information_impl import AccessInformationImpl
from app_admin.adapters.impl.law_enforcement_impl import LawEnforcementImpl
from app_admin.adapters.impl.type_organization_impl import TypeOrganizationImpl
from app_admin.adapters.impl.type_institution_impl import TypeInstitutionImpl
from app_admin.adapters.impl.function_organization_impl import FunctionOrganizationImpl
from app_admin.management.commands.configure_init.establishment_data import data
from app_admin.management.commands.configure_init.type_data import data_type_establishment
from app_admin.management.commands.configure_init.function_data import data_func
from app_admin.management.commands.configure_init.type_ogr_data import data_type_org

from app_admin.utils.function import progress_bar


class ConfigureService:

    def __init__(self) -> None:
        self.establishment_service = EstablishmentService(
            EstablishmentRepositoryImpl())
        self.access_info = AccessInformationService(AccessInformationImpl())
        self.law_enforcement = LawEnforcementService(LawEnforcementImpl())
        self.type_organization = TypeOrganizationImpl()
        self.type_institution = TypeInstitutionImpl()
        self.function_service = FunctionOrganizationImpl()
    def create_establishment_quantity(self, quantity: int):
        print("CREANDO INSTITUCIONES..")
        list_type_org = self.type_institution.get_all()
        list_type_inst = self.type_organization.get_all()
        list_func = self.function_service.get_all()
        slice = data[:quantity]
        for x in range(slice):
            print(progress_bar(x, quantity), end='\r', flush=True)
            print(progress_bar(x, len(data)), end='\r', flush=True)
            establishment_ = self.establishment_service.create_establishment({
                'name': establishment['Nombre Entidad'],
                'abbreviation': establishment['Nombre Entidad'],
                'highest_authority': "",
                'first_name_authority': establishment['Nombre Máxima Autoridad'].split()[0] if len(establishment['Nombre Máxima Autoridad'].split()) > 0 else "",
                'last_name_authority': establishment['Nombre Máxima Autoridad'].split()[0] if len(establishment['Nombre Máxima Autoridad'].split()) > 0 else "",
                'job_authority': "",
                'email_authority': "",
                'extra_numerals': [],
                'type_organization': list_type_org.filter(name=establishment['Tipo Organización']).first().id if list_type_org.filter(name=establishment['Tipo Organización']).exists() else None,
                'type_institution': list_type_inst.filter(name=establishment['Tipo Entidad']).first().id if list_type_inst.filter(name=establishment['Tipo Entidad']).exists() else None,
                'function_organization': list_func.filter(name=establishment['Función']).first().id if list_func.filter(name=establishment['Función']).exists() else None,
                'address': establishment['Direccion'],
                'identification': establishment['RUC'],

            }, None)
            access = self.access_info.create_access_information({
                'email_accesstoinformation': establishment['Correo electrónico para solicitudes de acceso']
            })
            self.access_info.assign_establishment_to_access_information(
                access.id, establishment_)
    
    def create_establishment(self):
        print("CREANDO INSTITUCIONES..")
        list_type_org = self.type_institution.get_all()
        list_type_inst = self.type_organization.get_all()
        list_func = self.function_service.get_all()
        for x, establishment in enumerate(data):
            print(progress_bar(x, len(data)), end='\r', flush=True)
            establishment_ = self.establishment_service.create_establishment({
                'name': establishment['Nombre Entidad'],
                'abbreviation': establishment['Nombre Entidad'],
                'highest_authority': "",
                'first_name_authority': establishment['Nombre Máxima Autoridad'].split()[0] if len(establishment['Nombre Máxima Autoridad'].split()) > 0 else "",
                'last_name_authority': establishment['Nombre Máxima Autoridad'].split()[0] if len(establishment['Nombre Máxima Autoridad'].split()) > 0 else "",
                'job_authority': "",
                'email_authority': "",
                'extra_numerals': [],
                'type_organization': list_type_org.filter(name=establishment['Tipo Organización']).first().id if list_type_org.filter(name=establishment['Tipo Organización']).exists() else None,
                'type_institution': list_type_inst.filter(name=establishment['Tipo Entidad']).first().id if list_type_inst.filter(name=establishment['Tipo Entidad']).exists() else None,
                'function_organization': list_func.filter(name=establishment['Función']).first().id if list_func.filter(name=establishment['Función']).exists() else None,
                'address': establishment['Direccion'],
                'identification': establishment['RUC'],

            }, None)
            access = self.access_info.create_access_information({
                'email_accesstoinformation': establishment['Correo electrónico para solicitudes de acceso']
            })
            self.access_info.assign_establishment_to_access_information(
                access.id, establishment_)

    def create_type_organization(self):
        print("Creando tipos de organizacion...")
        for type_org in data_type_org:
            self.type_organization.create_type_organization(
                type_org['Tipo Organización'])

    def create_type_institution(self):
        print("Creando tipo de instituciones")
        for type_inst in data_type_establishment:
            self.type_institution.create_type_institution(
                type_inst['Tipo Entidad'])

    def create_function_organization(self):
        print("creando funciones de organizaciones")
        for func in data_func:
            self.function_service.create_function_organization(func['funcion'])
