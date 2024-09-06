from entity_app.ports.repositories.solicity_repository import SolicityRepository
from datetime import datetime
from entity_app.domain.models.solicity import Insistency, Solicity, TimeLineSolicity, Status, Extension
from entity_app.adapters.messaging.publish import Publisher
from entity_app.adapters.messaging.channels import CHANNEL_SOLICIY
from entity_app.adapters.messaging.events import SOLICITY_CITIZEN_CREATED, SOLICITY_RESPONSE_ESTABLISHMENT, \
    SOLICITY_RESPONSE_USER, SOLICITY_FOR_EXPIRED, SOLICITY_USER_EXPIRED
from entity_app.domain.models.establishment import UserEstablishmentExtended
from datetime import timedelta


class SolicityService:

    def __init__(self, solicity_repository: SolicityRepository):
        self.solicity_repository = solicity_repository
        self.publisher = Publisher(CHANNEL_SOLICIY)

    def delete_draft(self, solicity_id, user_id):
        """
        Elimina un borrador de solicitud

        Args:
            solicity_id (int): id de la solicitud
            user_id (int): id del usuario

        Raises:
            ValueError: No se puede eliminar la solicitud
            ValueError: No

        Returns:
            _type_: _description_
        """

        solicity = self.solicity_repository.get_solicity_by_id(solicity_id)
        if solicity.user_created_id != user_id:
            raise ValueError("No se puede eliminar la solicitud")
        if solicity.status != Status.DRAFT:
            raise ValueError("No se puede eliminar la solicitud")
        return self.solicity_repository.delete_draft(solicity_id)

    def create_solicity_draft(self,
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
        """
        Crea una solicitud de ciudadano

        Args:
            solicity (dict): Diccionario con los datos de la solicitud de ciudadano
        """
        # return self.solicity_repository.create_citizen_solicity(title, text, establishment_id, user_id,expiry_date)
        return self.solicity_repository.create_solicity_draft(
            number_saip, establishment, city, first_name, last_name, email, phone,
            gender, race_identification, text, format_receipt, format_send, expiry_date, user_id)

    def send_solicity_from_draft(self,
                                 id: int,
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

        solicity = self.solicity_repository.send_solicity_from_draft(
            id, number_saip, establishment, city, first_name, last_name, email, phone,
            gender, race_identification, text, format_receipt, format_send, expiry_date, user_id)

        es = UserEstablishmentExtended.objects.filter(
            establishment_id=solicity.establishment_id).distinct().all()

        self.save_timeline(solicity.id, user_id, Status.SEND)
        self.publisher.publish({
            'type': SOLICITY_CITIZEN_CREATED,
            'payload': {
                'solicity_id': solicity.id,
                'establishment_id': solicity.establishment_id,
                'user_id': user_id,
                'number_saip': solicity.number_saip,
                'email': [e.user.email for e in es]
            }
        })

        return solicity

    def comment_solicity(self, solicity_id, user_id, text):
        """
        Crea un comentario en una solicitud

        Args:
            solicity_id (int): id de la solicitud
            user_id (int): id del usuario
            text (str): texto del comentario
        """
        return self.solicity_repository.create_comment_solicity(solicity_id, user_id, text)

    def change_status_by_id(self, solicity_id, user_id, text):
        return self.solicity_repository.change_status_by_id(solicity_id, text, user_id)

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

        solicity = self.solicity_repository.send_solicity_without_draft(
            number_saip, establishment, city, first_name, last_name, email, phone,
            gender, race_identification, text, format_receipt, format_send, expiry_date, user_id)

        es = UserEstablishmentExtended.objects.filter(
            establishment_id=solicity.establishment_id).distinct('user_id').all()
        self.publisher.publish({
            'type': SOLICITY_CITIZEN_CREATED,
            'payload': {
                'solicity_id': solicity.id,
                'establishment_id': solicity.establishment_id,
                'user_id': user_id,
                'number_saip': solicity.number_saip,
                'email': [e.user.email for e in es]

            }
        })

        return solicity

    def get_solicity_last_draft(self, user_id) -> Solicity | None:
        return self.solicity_repository.get_solicity_last_draft(user_id)

    def save_timeline(self, solicity_id, user_id, status) -> TimeLineSolicity:
        return self.solicity_repository.save_timeline(solicity_id, user_id, status)

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
                               date: datetime
                               ) -> Solicity:
        """
        Crea una solicitud de manual

        Args:
            solicity (dict): Diccionario con los datos de la solicitud de manual
        """

        solicity = self.solicity_repository.create_manual_solicity(
            number_saip, establishment, city, first_name, last_name, email, phone,
            gender, race_identification, text, format_receipt, format_send, expiry_date, user_id, date)

        es = UserEstablishmentExtended.objects.filter(
            establishment_id=solicity.establishment_id).distinct('user_id').all()
        self.publisher.publish({
            'type': SOLICITY_CITIZEN_CREATED,
            'payload': {
                'solicity_id': solicity.id,
                'establishment_id': solicity.establishment_id,
                'user_id': user_id,
                'number_saip': solicity.number_saip,
                'email': [e.user.email for e in es]

            }
        })

        return solicity

    def create_insistency_solicity(self, solicity_id, user_id, text):
        """
        Crea una solicitud de insitencia

        Args:
            extension (dict): Diccionario con los datos de la solicitud de insitencia
        """

        return self.solicity_repository.create_insistency_solicity(solicity_id, user_id, text)

    def create_extencion_solicity(self, motive, solicity_id, user_id, files, attachments):
        """
        Crea una prorroga

        Args:
            motive (dict): Diccionario con los datos de la prorroga
            solicity_id (int): id de la solicitud

        """

        return self.solicity_repository.create_extencion_solicity(motive, solicity_id, user_id, files, attachments)

    def create_solicity_response(self, solicity_id, user_id, text, files, attachments):
        """
        Crea una respuesta de solicitud

        Args:
            solicity_response (dict): Diccionario con los datos de la respuesta de solicitud
        """

        solicity = self.get_solicity_by_id(solicity_id)
        es = UserEstablishmentExtended.objects.filter(
            establishment_id=solicity.establishment_id).distinct('user_id').all()

        extensions = Extension.objects.filter(solicity=solicity).count()

        is_citizen = solicity.user_created_id == user_id

        # si el estado actual es enviado
        if solicity.status == Status.SEND:
            # si el usuario es no es el ciudadano
            if not is_citizen or solicity.is_manual:
                # si el usuario es el establecimiento response
                solicity.status = Status.RESPONSED
                solicity.save()
                self.save_timeline(solicity_id, user_id, Status.RESPONSED)
                self.solicity_repository.create_solicity_response(
                    solicity_id=solicity_id, user_id=user_id, text=text, files=files, attachments=attachments)
                self.publisher.publish({
                    'type': SOLICITY_RESPONSE_ESTABLISHMENT,
                    'payload': {
                        'solicity_id': solicity_id,
                        'user_id': solicity.user_created_id,
                        'number_saip': solicity.number_saip,
                        'establishment_id': solicity.establishment_id,
                        'email': [e.user.email for e in es]

                    }
                })

            return solicity

        if solicity.status == Status.PRORROGA:
            if not is_citizen or solicity.is_manual:
                self.solicity_repository.create_comment_solicity(
                    solicity_id=solicity_id,
                    text=text,
                    user_id=user_id
                )
                self.save_timeline(solicity_id, user_id, Status.PRORROGA)
                self.publisher.publish({
                    'type': SOLICITY_RESPONSE_ESTABLISHMENT,
                    'payload': {
                        'solicity_id': solicity_id,
                        'user_id': solicity.user_created_id,
                        'number_saip': solicity.number_saip,
                        'establishment_id': solicity.establishment_id,
                        'email': [e.user.email for e in es]

                    }
                })

            return solicity
        # si la solicitud esta en estado de respuesta
        if solicity.status == Status.RESPONSED:

            # validar si ya expiro la solicitud
            if is_citizen or solicity.is_manual:
                self.solicity_repository.create_insistency_solicity(
                    solicity_id, user_id, text)

                solicity.status = Status.INSISTENCY_SEND
                solicity.save()
                self.save_timeline(solicity_id, user_id,
                                   Status.INSISTENCY_SEND)

                self.publisher.publish({
                    'type': SOLICITY_RESPONSE_USER,
                    'payload': {
                        'solicity_id': solicity_id,
                        'user_id': solicity.user_created_id,
                        'number_saip': solicity.number_saip,
                        'establishment_id': solicity.establishment_id,
                        'email': [e.user.email for e in es]

                    }
                })

                return solicity
            else:
                raise ValueError(
                    "No se pueden agregar mas comentarios a esta solicitud")

        if solicity.status == Status.INSISTENCY_PERIOD:
            if is_citizen or solicity.is_manual:
                self.solicity_repository.create_insistency_solicity(
                    solicity_id, user_id, text)

                solicity.status = Status.INSISTENCY_SEND
                solicity.save()
                self.save_timeline(solicity_id, user_id,
                                   Status.INSISTENCY_SEND)

                self.publisher.publish({
                    'type': SOLICITY_RESPONSE_USER,
                    'payload': {
                        'solicity_id': solicity_id,
                        'user_id': solicity.user_created_id,
                        'number_saip': solicity.number_saip,
                        'establishment_id': solicity.establishment_id,
                        'email': [e.user.email for e in es]

                    }
                })

                return solicity
            else:
                raise ValueError(
                    "No se pueden agregar mas comentarios a esta solicitud")

        if solicity.status == Status.INSISTENCY_SEND:
            if is_citizen:
                raise ValueError(
                    "No se pueden agregar mas comentarios a esta solicitud durante el periodo de insitencia")

            else:

                self.solicity_repository.create_solicity_response(
                    solicity_id, user_id, text, files, attachments)
                solicity.status = Status.INSISTENCY_RESPONSED
                solicity.save()
                self.save_timeline(solicity_id, user_id,
                                   Status.INSISTENCY_RESPONSED)

                self.publisher.publish({
                    'type': SOLICITY_RESPONSE_ESTABLISHMENT,
                    'payload': {
                        'solicity_id': solicity_id,
                        'user_id': solicity.user_created_id,
                        'number_saip': solicity.number_saip,
                        'establishment_id': solicity.establishment_id,
                        'email': [e.user.email for e in es]

                    }
                })

            return solicity

        if solicity.status == Status.PERIOD_INFORMAL_MANAGEMENT:
            if is_citizen or solicity.is_manual:

                self.solicity_repository.create_insistency_solicity(
                    solicity_id, user_id, text)
                solicity.status = Status.INFORMAL_MANAGMENT_SEND
                solicity.save()
                self.save_timeline(solicity_id, user_id,
                                   Status.INFORMAL_MANAGMENT_SEND)
                self.publisher.publish({
                    'type': SOLICITY_RESPONSE_USER,
                    'payload': {
                        'solicity_id': solicity_id,
                        'user_id': solicity.user_created_id,
                        'number_saip': solicity.number_saip,
                        'establishment_id': solicity.establishment_id,
                        'email': [e.user.email for e in es]

                    }
                })

                return solicity
            else:

                raise ValueError(
                    " No se pueden agregar mas comentarios a esta solicitud")

        if solicity.status == Status.INFORMAL_MANAGMENT_SEND:
            if is_citizen:
                raise ValueError(
                    "No se pueden agregar mas comentarios a esta solicitud durante el periodo de insitencia")
            else:
                solicity.status = Status.INFORMAL_MANAGMENT_RESPONSED
                solicity.save()
                self.save_timeline(solicity_id, user_id,
                                   Status.INFORMAL_MANAGMENT_RESPONSED)
                self.solicity_repository.create_solicity_response(
                    solicity_id, user_id, text, files, attachments)
                self.publisher.publish({
                    'type': SOLICITY_RESPONSE_ESTABLISHMENT,
                    'payload': {
                        'solicity_id': solicity_id,
                        'user_id': solicity.user_created_id,
                        'number_saip': solicity.number_saip,
                        'establishment_id': solicity.establishment_id,
                        'email': [e.user.email for e in es]

                    }
                })

                return solicity

        return solicity

    def update_solicity(self,
                        id: int,
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
                        is_send: bool,
                        user_id: int) -> Solicity:
        if is_send:
            return self.send_solicity_from_draft(
                id, number_saip, establishment, city, first_name, last_name, email, phone,
                gender, race_identification, text, format_receipt, format_send, expiry_date, user_id)
        else:
            return self.update_draft(
                id, number_saip, establishment, city, first_name, last_name, email, phone,
                gender, race_identification, text, format_receipt, format_send, expiry_date, user_id)

    def update_draft(
        self, id, number_saip, establishment, city, first_name, last_name, email, phone,
        gender, race_identification, text, format_receipt, format_send, expiry_date, user_id
    ):
        return self.solicity_repository.update_draft(id, number_saip, establishment, city, first_name, last_name, email, phone,
                                                     gender, race_identification, text, format_receipt, format_send, expiry_date, user_id
                                                     )

    def update_solicity_response(self, solicity_response_id, text, category_id, files, attachments):
        """
        Actualiza una respuesta de solicitud

        Args:
            solicity_response (dict): Diccionario con los datos de la respuesta de solicitud
        """
        return self.solicity_repository.update_solicity_response(solicity_response_id, text, category_id, files, attachments)

    def delete_solicity_response(self, solicity_response_id, user_id):
        """
        Elimina una respuesta de solicitud

        Args:
            solicity_response_id (int): id de la respuesta de solicitud
        """
        return self.solicity_repository.delete_solicity_response(solicity_response_id, user_id)

    def get_user_solicities(self, user_id):
        """
        Obtiene las solicitudes de un usuario

        Args:
            user_id (int): id del usuario
        """
        return self.solicity_repository.get_user_solicities(user_id)

    def get_entity_solicities(self, entity_id):
        """
        Obtiene las solicitudes de una entidad

        Args:
            entity_id (int): id de la entidad
        """
        return self.solicity_repository.get_entity_solicities(entity_id)

    def get_solicity_by_id(self, solicity_id):
        """
        Obtiene una solicitud por id

        Args:
            solicity_id (int): id de la solicitud
        """
        try:
            return self.solicity_repository.get_solicity_by_id(solicity_id)
        except Exception as e:

            raise ValueError("No se encontro la solicitud")

    def validate_user_establishment(self, user_id, establishment_id):
        """
        Valida si el usuario pertenece al establecimiento

        Args:
            user_id (int): id del usuario
            establishment_id (int): id del establecimiento
        """
        return self.solicity_repository.validate_user_establishment(user_id, establishment_id)

    def get_entity_user_solicities(self, user_id):
        """
        Obtiene las solicitudes de un usuario en sus establecimientos

        Args:
            user_id (int): id del usuario
        """
        return self.solicity_repository.get_entity_user_solicities(user_id)

    def get_solicity_by_id_and_user(self, solicity_id, user_id):
        """
        Obtiene una solicitud por id y usuario

        Args:
            solicity_id (int): id de la solicitud
            user_id (int): id del usuario
        """
        try:
            return self.solicity_repository.get_solicity_by_id_and_user(solicity_id, user_id)
        except Exception as e:
            raise ValueError("No se encontro la solicitud")
