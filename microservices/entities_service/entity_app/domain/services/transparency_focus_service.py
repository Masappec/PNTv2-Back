from entity_app.ports.repositories.transparency_focus_repository import TransparencyFocusRepository

class TransparencyFocusService:

    def __init__(self, transparency_focus_repository: TransparencyFocusRepository):
        self.transparency_focus_repository = transparency_focus_repository

    def createTransparencyFocus(self, establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha):
        return self.transparency_focus_repository.createTransparencyFocus(establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha)
    
    def getTransparencyColaborativeUser(self, user_id):
        return self.transparency_focus_repository.getTransparencyFocusUser(user_id)
    
    def deleteTransparencyColaborativeUser(self, pk, user_id):
        return self.transparency_focus_repository.deleteTransparencyFocusUser(pk, user_id)
