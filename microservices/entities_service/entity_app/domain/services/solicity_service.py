from entity_app.ports.repositories.solicity_repository import SolicityRepository

class SolicityService:

    def __init__(self, solicity_repository: SolicityRepository):
        self.solicity_repository = solicity_repository
    
    def create_citizen_solicity(self, title, text, establishment_id, user_id, expiry_date):
        return self.solicity_repository.create_citizen_solicity(title, text, establishment_id, user_id, expiry_date)
    
    def validate_user_establishment(self, establishment_id, user_id):
        return self.solicity_repository.validate_user_establishmentt(establishment_id, user_id)
    
    def create_solicity_response(self, solicity_id, user_id, text, category_id, files, attachments):
        return self.solicity_repository.create_solicity_response(solicity_id, user_id, text, category_id, files, attachments)