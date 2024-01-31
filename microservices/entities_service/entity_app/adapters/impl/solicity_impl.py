from entity_app.ports.repositories.solicity_repository import SolicityRepository
from entity_app.domain.models.solicity import Insistency, Solicity, SolicityResponse, Status, Extension
from entity_app.domain.models.publication import Attachment, FilePublication
from entity_app.domain.models.establishment import UserEstablishmentExtended
from datetime import datetime

class SolicityImpl(SolicityRepository):

    def create_citizen_solicity(self, title, text, establishment_id, user_id, expiry_date):
        """
        Crea una solicitud de ciudadano

        Args:
            solicity (dict): Diccionario con los datos de la solicitud de ciudadano
        """
        solicity = Solicity.objects.create(title=title, text=text, establishment_id=establishment_id, user_id=user_id,
                                           user_created_id=user_id, user_updated_id=user_id, status=Status.CREATED, expiry_date=expiry_date)

        return solicity

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
        return Insistency.objects.create(solicity_id=solicity_id, user_id=user_id, title=title, text=text, user_created_id=user_id, user_updated_id=user_id, status=Status.CREATED)

    def create_manual_solicity(self, title, text, establishment_id, user_id, expiry_date):
        return Solicity.objects.create(title=title, text=text, establishment_id=establishment_id, user_id=user_id,
                                       user_created_id=user_id, user_updated_id=user_id, status=Status.CREATED, expiry_date=expiry_date,
                                       is_manual=True)

    def create_solicity_response(self, solicity_id, user_id, text, category_id, files, attachments):

        file_instances = FilePublication.objects.filter(id__in=files)

        attachments_instances = Attachment.objects.filter(id__in=attachments)

        response = SolicityResponse.objects.create(solicity_id=solicity_id, user_id=user_id, text=text, category_id=category_id,
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
        return Solicity.objects.filter(user_id=user_id, is_active=True)
    
    
    
    def get_entity_solicities(self, entity_id):
        return Solicity.objects.filter(establishment__id=entity_id, is_active=True)
    
    
    
    def delete_solicity_response(self, solicity_response_id,user_id):
        return SolicityResponse.objects.filter(id=solicity_response_id).update(is_active=False,deteled_at=datetime.now(),user_deleted_id=user_id)
    
    def validate_user_establishment(self, establishment_id, user_id):
        return UserEstablishmentExtended.objects.filter(user_id=user_id, establishment_id=establishment_id).exists()