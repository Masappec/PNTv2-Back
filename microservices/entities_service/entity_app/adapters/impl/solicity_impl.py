from entity_app.ports.repositories.solicity_repository import SolicityRepository
from entity_app.domain.models.solicity import Insistency, Solicity, SolicityResponse, Status, Extension, TimeLineSolicity
from entity_app.domain.models.publication import Attachment, FilePublication
from entity_app.domain.models.establishment import UserEstablishmentExtended
from datetime import datetime
from django.contrib.auth.models import User
from django.db.models import QuerySet
from entity_app.domain.models.solicity import Solicity, TimeLineSolicity, TypeStages


class SolicityImpl(SolicityRepository):

    # def create_citizen_solicity(self, title, text, establishment_id, user_id, expiry_date):
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

        solicity = Solicity.objects.filter(
            user_created_id=user_id, status=Status.DRAFT).last()

        if solicity is None:

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

        else:
            solicity.number_saip = number_saip
            solicity.establishment_id = establishment_id
            solicity.city = city
            solicity.first_name = first_name
            solicity.last_name = last_name
            solicity.email = email
            solicity.phone = phone
            solicity.race_identification = race_identification
            solicity.description = description
            solicity.format_receipt = format_receipt
            solicity.format_send = format_send
            solicity.expiry_date = expiry_date
            solicity.user_updated = user
            solicity.status = Status.DRAFT
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
        TimeLineSolicity.objects.create(
            solicity_id=solicity.id, status=TypeStages.SEND)
        return solicity

    def get_solicity_last_draft(self, user_id) -> Solicity | None:
        data = Solicity.objects.filter(
            user_created_id=user_id, status=Status.DRAFT).first()
        print("data", data)
        return data

    def save_timeline(self, solicity_id, user_id, status) -> TimeLineSolicity:
        return TimeLineSolicity.objects.create(solicity_id=solicity_id, user_id=user_id, status=status)

    def create_extencion_solicity(self, motive, solicity_id, user_id):
        """
        Crea una prorroga

        Args:
            motive (str): motivo de la prorroga
            solicity_id (int): id de la solicitud
            user_id (int): id del usuario que crea la prorroga

        Returns:
            Insistency: instancia de la prorroga
        """

        return Extension.objects.create(motive=motive, solicity_id=solicity_id, user_id=user_id, user_created_id=user_id, user_updated_id=user_id, status=Status.CREATED)

    def create_insistency_solicity(self, solicity_id, user_id, title, text):
        TimeLineSolicity.objects.create(solicity_id, TypeStages.INSISTENCY)

        return Insistency.objects.create(solicity_id=solicity_id, user_id=user_id, title=title, text=text, user_created_id=user_id, user_updated_id=user_id, status=Status.CREATED)

    def create_manual_solicity(self, title, text, establishment_id, user_id, expiry_date):
        return Solicity.objects.create(title=title, text=text, establishment_id=establishment_id, user_id=user_id,
                                       user_created_id=user_id, user_updated_id=user_id, status=Status.CREATED, expiry_date=expiry_date,
                                       is_manual=True)

    def create_solicity_response(self, solicity_id, user_id, text, category_id, files, attachments):

        file_instances = FilePublication.objects.filter(id__in=files)

        attachments_instances = Attachment.objects.filter(id__in=attachments)

        insistenci = Insistency.objects.filter(
            solicity_id=solicity_id, user_id=user_id, status=Status.CREATED).exists()
        response = SolicityResponse.objects.create(solicity_id=solicity_id, user_id=user_id, text=text,
                                                   category_id=category_id,
                                                   user_created_id=user_id, user_updated_id=user_id)
        status = TypeStages.RESPONSE_INSISTENCY if insistenci else Status.PROCESSING

        TimeLineSolicity.objects.create(
            solicity_id, status)

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

        TimeLineSolicity.objects.create(
            response.solicity_id, TypeStages.RESPONSE)

        return response

    def get_user_solicities(self, user_id):
        return Solicity.objects.filter(user_created_id=user_id, is_active=True, status__in=[Status.READING, Status.SEND,
                                                                                            Status.PROCESSING, Status.FINISHED])

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
            return ValueError('User does not have an establishment')
        return Solicity.objects.filter(establishment_id=establishment.establishment_id,
                                       is_active=True, status__in=[Status.READING, Status.SEND,
                                                                   Status.PROCESSING, Status.FINISHED])

    def get_solicity_by_id_and_user(self, solicity_id, user_id):
        return Solicity.objects.get(id=solicity_id, user_created_id=user_id)
