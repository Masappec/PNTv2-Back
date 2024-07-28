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

    def update_transparency_focus(self, pk, user_id, newfiles):

        return self.transparency_focus_repository.update_transparency_focus(pk, user_id, newfiles)

    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        return self.transparency_focus_repository.get_by_year_month(year, month, establishment_id)
    
    
    def get_by_year(self, year: int, establishment_id: int):
        return self.transparency_focus_repository.get_by_year(year, establishment_id)


    def get_months_by_year(self, year: int, establishment_id: int):
        return self.transparency_focus_repository.get_months_by_year(year, establishment_id)
    
    
    def get_all_year_month(self, year: int, month: int):
        return self.transparency_focus_repository.get_all_year_month(year, month)
    
    