import json
import os
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
from django.contrib.auth.models import Group, User

from app_admin.utils.function import progress_bar
from app_admin.domain.models.base_model import BaseModel
from shared.tasks.user_task import send_user_created_event
from datetime import datetime
from django.contrib.auth.models import AbstractUser, Permission
from django.db import connection, models
from django.contrib.auth.hashers import make_password




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
        for x, establishment in enumerate(slice):
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
            
            
    def create_establishment_user(self):
        dir = os.path.dirname(__file__)
        dir = os.path.join(dir, 'user.json')
        print('leyendo archivo')
        list_type_org = self.type_institution.get_all()
        list_type_inst = self.type_organization.get_all()
        list_func = self.function_service.get_all()
        role = Group.objects.filter(name='Supervisora PNT').first()
        if role is None:
            print('No existe el ROL Supervisora PNT, debe crearlo')
            return
        with open(dir, encoding='utf-8') as file:
            userstocreate = json.load(file)
            for x, _data in enumerate(userstocreate):
                print(progress_bar(x, userstocreate.__len__()),
                      end='\r', flush=True)
                print(progress_bar(x, len(userstocreate)), end='\r', flush=True)
                establishment_ = self.establishment_service.get_by_identification(
                    _data['ruc'])
                if establishment_ is None:
                    establishment_ = self.establishment_service.create_establishment({
                        'name': _data['name'],
                        'alias':  _data['name'],
                        'abbreviation': _data['name'],
                        'highest_authority': "",
                        'first_name_authority':"",
                        'last_name_authority': "",
                        'job_authority': "",
                        'email_authority': "",
                        'extra_numerals': [],
                        'type_organization': None,
                        'type_institution': None,
                        'function_organization': list_func.filter(name=_data['funcion']).first().id if list_func.filter(name=_data['funcion']).exists() else None,
                        'address': "",
                        'identification': str(_data['ruc']),
                    },None)
                
                data_user = {
                    'username': str(_data['usuario']),
                    'email': str(_data['usuario']) + '@correo.com',
                    'password': make_password(str(_data['clave'])),
                    'first_name': "Usuario",
                    'last_name': "Supervisor",
                    'created_at': datetime.now()
                    
                }
                

                
                try:
                    
                    
                    
                    with connection.cursor() as cursor:
                        
                        cursor.execute('''DELETE FROM auth_person WHERE user_id = (SELECT id FROM auth_user WHERE username = %s);''',[data_user['username']])
                        userdeleted = User.objects.filter(
                            username=data_user['username']).delete()

                        cursor.execute('''INSERT INTO auth_user(username, email, 
                                            password, first_name, last_name, is_superuser,
                                            is_staff,is_active,date_joined,created_at,updated_at,deleted)
                                VALUES(%s, %s, %s,
                            %s, %s, false,false,
                            true,%s,%s,%s,%s)''',
                            [
                                data_user['username'],
                                data_user['email'],
                                data_user['password'],
                                data_user['first_name'],
                                data_user['last_name'],
                                datetime.now(),
                                datetime.now(),
                                datetime.now(),
                                False
                            ])
                        user = User.objects.filter(
                            username=data_user['username']).first()
                        
                        if user is None:
                            raise ValueError('Usuario no insertado')
                        
                        
                        cursor.execute('''
                                        INSERT INTO auth_user_groups (user_id, group_id) VALUES (%s, %s);
                                        '''
                                       ,[
                                           user.id,
                                           role.id
                                       ])
                        
                        cursor.execute(''' INSERT INTO auth_person(
                                            first_name,
                                            last_name,
                                            identification,
                                            phone,
                                            city,
                                            race,
                                            disability,
                                            age_range,
                                            province,
                                            accept_terms,
                                            gender,
                                            user_id
                                        )
                                        VALUES (
                                            %s,
                                            %s,
                                            %s,
                                            %s,
                                            %s,
                                            %s,
                                            %s,
                                            %s,
                                            %s,
                                            %s,
                                            %s,
                                            %s
                                        );''',
                                        [
                                            "Usuario",
                                            "Supervisor",
                                            _data['ruc'],
                                            "NO",
                                            "NO",
                                            "NO",
                                            "NO",
                                            "NO",
                                            "NO",
                                            True,
                                            "NO",
                                            user.id
                                        ])
                        
                        send_user_created_event(user.id,establishment_.id)
                    
                    
                    
                except Exception as e:
                    print(e,_data)
                    continue
                finally:
                    cursor.close()

    def create_establishment(self):
        print("CREANDO INSTITUCIONES..")
        list_type_org = self.type_institution.get_all()
        list_type_inst = self.type_organization.get_all()
        list_func = self.function_service.get_all()
        data_copy = data.copy()
        data_copy = data_copy[:100]
        for x, establishment in enumerate(data_copy):
            print(progress_bar(x, len(data_copy)), end='\r', flush=True)
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
