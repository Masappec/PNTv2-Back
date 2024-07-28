from entity_app.ports.repositories.solicity_repository import SolicityRepository
from entity_app.domain.models.solicity import Insistency, Solicity, SolicityResponse, Status, Extension, TimeLineSolicity
from entity_app.domain.models.publication import Attachment, FilePublication
from entity_app.domain.models.establishment import UserEstablishmentExtended
from datetime import datetime
from django.contrib.auth.models import User
from django.db.models import QuerySet
from entity_app.domain.models.solicity import Solicity, TimeLineSolicity, TypeStages
from entity_app.utils.functions import get_time_prorroga, get_timedelta_for_expired
from django.utils import timezone
class SolicityImpl(SolicityRepository):

    def change_status_by_id(self, solicity_id,text,user_id)->Solicity:
        solicity = Solicity.objects.get(id=solicity_id)
        
        
        if timezone.now() > solicity.expiry_date:
            newstatus = ''
            
            
            if solicity.status == Status.RESPONSED or solicity.status == Status.NO_RESPONSED:
                newstatus = Status.INSISTENCY_SEND

                
            if solicity.status == Status.INSISTENCY_RESPONSED or solicity.status == Status.INSISTENCY_NO_RESPONSED:    
                newstatus = Status.INFORMAL_MANAGMENT_SEND

            if newstatus=='':
                raise ValueError('Esta solicitud aun está vigente')
            
            
            solicity.status = newstatus
            solicity.expiry_date = solicity.expiry_date +get_timedelta_for_expired()


            Insistency.objects.create(solicity_id=solicity_id,
                                            user_id=user_id,  motive=text,
                                            user_created_id=user_id,
                                            user_updated_id=user_id,
                                            status=Status.SEND)
            solicity.save()
            self.save_timeline(
                solicity_id, solicity.user_created_id, newstatus)

            return solicity
        else:
            if solicity.status == Status.SEND:
                newstatus = Status.PRORROGA
                solicity.status = newstatus
                
                solicity.expiry_date = datetime.now()+get_time_prorroga()
                solicity.save()
                self.save_timeline(
                    solicity_id, solicity.user_created_id, newstatus)
                
                comment = Extension.objects.create(solicity_id=solicity_id,
                                            user_id=user_id,  motive=text,
                                            user_created_id=user_id,
                                            user_updated_id=user_id,
                                            status=Status.PRORROGA)
                return solicity
            if solicity.status == Status.RESPONSED or solicity.status == Status.NO_RESPONSED:
                solicity.status = Status.INSISTENCY_SEND
                solicity.expiry_date = solicity.expiry_date +get_time_prorroga()
                solicity.save()
                
                Insistency.objects.create(solicity_id=solicity_id,
                                            user_id=user_id,  motive=text,
                                            user_created_id=user_id,
                                            user_updated_id=user_id,
                                          status=Status.INSISTENCY_SEND)
                self.save_timeline(
                    solicity_id, solicity.user_created_id, Status.INSISTENCY_PERIOD)
                return solicity
            raise ValueError('Esta solicitud aun está vigente')
    def create_solicity_draft(self,
                              number_saip: str,
                              establishment_id: int,
                              city: str,
                              first_name: str,
                              last_name: str,
                              email: str,
                              phone: str,
                              gender: str,
                              race_identification: str,
                              description: str,
                              format_receipt: str,
                              format_send: str,
                              expiry_date: datetime,
                              user_id: int) -> Solicity:
        """
        Crea una solicitud de ciudadano

        Args:
            solicity (dict): Diccionario con los datos de la solicitud de ciudadano
        """
        user = User.objects.get(id=user_id)

        


        solicity = Solicity.objects.create(
            number_saip=number_saip,
            establishment_id=establishment_id.pk,
            city=city,
            first_name=first_name,
            last_name=last_name,
            email=email,
            phone=phone,
            gender=gender,
            race_identification=race_identification,
            text=description,
            format_receipt=format_receipt,
            format_send=format_send,
            expiry_date=expiry_date,
            user_created=user,
            user_updated=user,
            status=Status.DRAFT)

   
        solicity.number_saip = f'{solicity.id}/{solicity.date.year}'
        solicity.save()
        return solicity

    def send_solicity_from_draft(self,
                                 solicity_id: int,
                                 number_saip: str,
                                 establishment: int,
                                 city: str,
                                 first_name: str,
                                 last_name: str,
                                 email: str,
                                 phone: str,
                                 gender: str,
                                 race_identification: str,
                                 description: str,
                                 format_receipt: str,
                                 format_send: str,
                                 expiry_date: datetime,
                                 user_id: int) -> Solicity:

        user = User.objects.get(id=user_id)
        solicity = Solicity.objects.get(id=solicity_id)
        solicity.number_saip = number_saip
        solicity.establishment_id = establishment.pk
        solicity.city = city
        solicity.first_name = first_name
        solicity.last_name = last_name
        solicity.email = email
        solicity.phone = phone
        solicity.gender = gender
        solicity.race_identification = race_identification
        solicity.description = description
        solicity.format_receipt = format_receipt
        solicity.format_send = format_send
        solicity.expiry_date = expiry_date
        solicity.user_updated = user
        solicity.status = Status.SEND
        solicity.save()
        solicity.number_saip = f'SAIP-{solicity.date.year}-{solicity.id}'
        solicity.save()
        return solicity

    def send_solicity_without_draft(self,
                                    number_saip: str,
                                    establishment: int,
                                    city: str,
                                    first_name: str,
                                    last_name: str,
                                    email: str,
                                    phone: str,
                                    gender: str,
                                    race_identification: str,
                                    text: str,
                                    format_receipt: str,
                                    format_send: str,
                                    expiry_date: datetime,
                                    user_id: int) -> Solicity:
        user = User.objects.get(id=user_id)

        solicity = Solicity.objects.create(
            number_saip=number_saip,
            establishment_id=establishment.pk,
            city=city,
            first_name=first_name,
            last_name=last_name,
            email=email,
            phone=phone,
            gender=gender,
            race_identification=race_identification,
            text=text,
            format_receipt=format_receipt,
            format_send=format_send,
            expiry_date=expiry_date,
            user_created=user,
            user_updated=user,
            status=Status.SEND)
        solicity.number_saip = f'SAIP-{solicity.date.year}-{solicity.id}'
        solicity.save()
        TimeLineSolicity.objects.create(
            solicity_id=solicity.id, status=Status.SEND)
        return solicity

    def get_solicity_last_draft(self, user_id) -> Solicity | None:
        data = Solicity.objects.filter(
            user_created_id=user_id, status=Status.DRAFT).first()
        print("data", data)
        return data

    def save_timeline(self, solicity_id, user_id, status) -> TimeLineSolicity:
        return TimeLineSolicity.objects.create(solicity_id=solicity_id, user_created_id=user_id, status=status)

    def create_extencion_solicity(self, motive, solicity_id, user_id, files, attachments):
        """
        Crea una prorroga

        Args:
            motive (str): motivo de la prorroga
            solicity_id (int): id de la solicitud
            user_id (int): id del usuario que crea la prorroga

        Returns:
            Insistency: instancia de la prorroga
        """

        ext = Extension.objects.create(motive=motive, solicity_id=solicity_id, user_id=user_id,
                                       user_created_id=user_id, user_updated_id=user_id, status=Status.SEND)
        ext.files.set(files)
        ext.attachments.set(attachments)
        return ext

    def create_insistency_solicity(self, solicity_id, user_id, text):

        return Insistency.objects.create(solicity_id=solicity_id,
                                         user_id=user_id,  motive=text,
                                         user_created_id=user_id,
                                         user_updated_id=user_id,
                                         status=Status.SEND)

    def create_comment_solicity(self, solicity_id, user_id, text):
        
        solicity = Solicity.objects.get(id=solicity_id)
        return Extension.objects.create(solicity_id=solicity_id,
                                        user_id=user_id,  motive=text,
                                        user_created_id=user_id,
                                        user_updated_id=user_id,
                                        status=solicity.status)

    def create_manual_solicity(self,
                               number_saip: str,
                               establishment: int,
                               city: str,
                               first_name: str,
                               last_name: str,
                               email: str,
                               phone: str,
                               gender: str,
                               race_identification: str,
                               text: str,
                               format_receipt: str,
                               format_send: str,
                               expiry_date: datetime,
                               user_id: int,
                            date: datetime,
                               ) -> Solicity:
        user = User.objects.get(id=user_id)

        solicity = Solicity.objects.create(
            number_saip=number_saip,
            establishment_id=establishment.pk,
            city=city,
            first_name=first_name,
            last_name=last_name,
            email=email,
            phone=phone,
            gender=gender,
            race_identification=race_identification,
            text=text,
            format_receipt=format_receipt,
            format_send=format_send,
            expiry_date=expiry_date,
            user_created=user,
            user_updated=user,
            status=Status.SEND,
            date=date,
            is_manual=True)
        
        solicity.number_saip = f'SAIP-{solicity.date.year}-{solicity.id}'
        solicity.save()
        TimeLineSolicity.objects.create(
            solicity_id=solicity.id, status=Status.SEND)
        return solicity

    def create_solicity_response(self, solicity_id, user_id, text, files, attachments):

        file_instances = FilePublication.objects.filter(id__in=files)

        attachments_instances = Attachment.objects.filter(id__in=attachments)

        response = SolicityResponse.objects.create(solicity_id=solicity_id,
                                                   user_id=user_id,
                                                   text=text,
                                                   user_created_id=user_id, user_updated_id=user_id)

        response.files.set(file_instances)
        response.attachments.set(attachments_instances)

        return response

    def update_solicity_response(self, solicity_response_id, text, category_id, files, attachments):

        file_instances = FilePublication.objects.filter(id__in=files)

        attachments_instances = Attachment.objects.filter(id__in=attachments)

        response = SolicityResponse.objects.get(id=solicity_response_id)

        response.text = text
        response.category_id = category_id

        response.files.set(file_instances)
        response.attachments.set(attachments_instances)

        response.save()

        return response

    def get_user_solicities(self, user_id):
        return Solicity.objects.filter(user_created_id=user_id, is_active=True).order_by('-created_at')

    def get_entity_solicities(self, entity_id):
        return Solicity.objects.filter(establishment__id=entity_id, is_active=True)

    def delete_solicity_response(self, solicity_response_id, user_id):
        return SolicityResponse.objects.filter(id=solicity_response_id).update(is_active=False, deteled_at=datetime.now(), user_deleted_id=user_id)

    def validate_user_establishment(self, establishment_id, user_id):
        return UserEstablishmentExtended.objects.filter(user_id=user_id, establishment_id=establishment_id, is_active=True).exists()

    def get_entity_user_solicities(self, user_id):
        establishment = UserEstablishmentExtended.objects.filter(
            user_id=user_id, is_active=True).first()
        if establishment is None:
            
            return Solicity.objects.all().filter(is_active=True).exclude(status=Status.DRAFT) 
            
        return Solicity.objects.filter(establishment_id=establishment.establishment_id,
                                       is_active=True
                                       ).exclude(status=Status.DRAFT)

    def get_solicity_by_id_and_user(self, solicity_id, user_id):
        establishment = UserEstablishmentExtended.objects.filter(
            user_id=user_id, is_active=True).first()
        if establishment is None:
            return Solicity.objects.get(id=solicity_id)
        else:
            return Solicity.objects.get(id=solicity_id, user_created_id=user_id)

    def get_solicity_by_id(self, solicity_id):
        return Solicity.objects.get(id=solicity_id)
