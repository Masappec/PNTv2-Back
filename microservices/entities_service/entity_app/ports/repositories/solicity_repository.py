from abc import ABC, abstractmethod

from datetime import datetime
from entity_app.models import Solicity


class SolicityRepository(ABC):

    @abstractmethod
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
        pass

    @abstractmethod
    def send_solicity_from_draft(self,
                                 solicity_id: int,
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
        pass

    @abstractmethod
    def send_solicity_without_draft(self,
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
        pass

    @abstractmethod
    def get_solicity_last_draft(self, user_id) -> Solicity | None:
        pass

    @abstractmethod
    def save_timeline(self, solicity_id, user_id, status):
        pass

    @abstractmethod
    def create_manual_solicity(self, title, text, establishment_id, user_id, expiry_date):
        """
        Crea una solicitud de manual

        Args:
            solicity (dict): Diccionario con los datos de la solicitud de manual
        """
        pass

    @abstractmethod
    def create_insistency_solicity(self, solicity_id, user_id, title, text):
        """
        Crea una solicitud de insitencia

        Args:
            extension (dict): Diccionario con los datos de la solicitud de insitencia
        """
        pass

    @abstractmethod
    def create_extencion_solicity(self, motive, solicity_id, user_id):
        """
        Crea una prorroga

        Args:
            motive (dict): Diccionario con los datos de la prorroga
            solicity_id (int): id de la solicitud
        """
        pass

    @abstractmethod
    def create_solicity_response(self, solicity_id, user_id, text, category, files, attachments):
        """
        Crea una respuesta de solicitud

        Args:
            solicity_response (dict): Diccionario con los datos de la respuesta de solicitud
        """
        pass

    @abstractmethod
    def update_solicity_response(self, solicity_response_id, text, category_id, files, attachments):
        """
        Actualiza una respuesta de solicitud

        Args:
            solicity_response (dict): Diccionario con los datos de la respuesta de solicitud
        """
        pass

    @abstractmethod
    def delete_solicity_response(self, solicity_response_id, user_id):
        """
        Elimina una respuesta de solicitud

        Args:
            solicity_response_id (int): id de la respuesta de solicitud
        """
        pass

    @abstractmethod
    def get_user_solicities(self, user_id):
        """
        Obtiene las solicitudes de un usuario

        Args:
            user_id (int): id del usuario

        Returns:
            list: Lista de solicitudes
        """
        pass

    @abstractmethod
    def get_entity_solicities(self, entity_id):
        """
        Obtiene las solicitudes de una entidad

        Args:
            entity_id (int): id de la entidad

        Returns:
            list: Lista de solicitudes
        """
        pass

    @abstractmethod
    def validate_user_establishment(self, establishment_id, user_id):
        pass

    @abstractmethod
    def get_entity_user_solicities(self, user_id):
        """
        Obtiene las solicitudes de un usuario en una entidad

        Args:
            entity_id (int): id de la entidad
            user_id (int): id del usuario

        Returns:
            list: Lista de solicitudes
        """
        pass

    @abstractmethod
    def get_solicity_by_id_and_user(self, solicity_id, user_id) -> Solicity:
        pass
