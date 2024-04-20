from entity_app.ports.repositories.solicity_repository import SolicityRepository
from datetime import datetime
from entity_app.domain.models.solicity import Solicity, TimeLineSolicity


class SolicityService:

    def __init__(self, solicity_repository: SolicityRepository):
        self.solicity_repository = solicity_repository

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

        return self.solicity_repository.send_solicity_from_draft(
            id, number_saip, establishment, city, first_name, last_name, email, phone,
            gender, race_identification, text, format_receipt, format_send, expiry_date, user_id)

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

        return self.solicity_repository.send_solicity_without_draft(
            number_saip, establishment, city, first_name, last_name, email, phone,
            gender, race_identification, text, format_receipt, format_send, expiry_date, user_id)

    def get_solicity_last_draft(self, user_id) -> Solicity | None:
        return self.solicity_repository.get_solicity_last_draft(user_id)

    def save_timeline(self, solicity_id, user_id, status) -> TimeLineSolicity:
        return self.solicity_repository.save_timeline(solicity_id, user_id, status)

    def create_manual_solicity(self, title, text, establishment_id, user_id, expiry_date):
        """
        Crea una solicitud de manual

        Args:
            solicity (dict): Diccionario con los datos de la solicitud de manual
        """
        return self.solicity_repository.create_manual_solicity(title, text, establishment_id, user_id, expiry_date)

    def create_insistency_solicity(self, solicity_id, user_id, title, text):
        """
        Crea una solicitud de insitencia

        Args:
            extension (dict): Diccionario con los datos de la solicitud de insitencia
        """
        return self.solicity_repository.create_insistency_solicity(solicity_id, user_id, title, text)

    def create_extencion_solicity(self, motive, solicity_id, user_id):
        """
        Crea una prorroga

        Args:
            motive (dict): Diccionario con los datos de la prorroga
            solicity_id (int): id de la solicitud

        """

        return self.solicity_repository.create_extencion_solicity(motive, solicity_id, user_id)

    def create_solicity_response(self, solicity_id, user_id, text, files, attachments):
        """
        Crea una respuesta de solicitud

        Args:
            solicity_response (dict): Diccionario con los datos de la respuesta de solicitud
        """
        return self.solicity_repository.create_solicity_response(solicity_id, user_id, text, files, attachments)

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
                        user_id: int) -> Solicity:

        return self.send_solicity_from_draft(
            id, number_saip, establishment, city, first_name, last_name, email, phone,
            gender, race_identification, text, format_receipt, format_send, expiry_date, user_id)

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
