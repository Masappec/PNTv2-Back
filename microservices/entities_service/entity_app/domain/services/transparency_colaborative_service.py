from entity_app.ports.repositories.transparency_colaborative_repository import TransparencyColaborativeRepository


class TransparencyColaborativeService:

    def __init__(self, transparency_colaborative_repository: TransparencyColaborativeRepository):
        self.transparency_colaborative_repository = transparency_colaborative_repository

    def createTransparencyColaborative(self, establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha):
        return self.transparency_colaborative_repository.createTransparencyColaborative(establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha)

    def getTransparencyColaborativeUser(self, user_id):
        return self.transparency_colaborative_repository.getTransparencyColaborativeUser(user_id)

    def deleteTransparencyColaborativeUser(self, pk, user_id):
        return self.transparency_colaborative_repository.deleteTransparencyColaborativeUser(pk, user_id)

    def update_transparency_colaborative(self, pk, user_id, newfiles):
        return self.transparency_colaborative_repository.update_transparency_colaborative(pk, user_id, newfiles)

    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        return self.transparency_colaborative_repository.get_by_year_month(year, month, establishment_id)

    
    def get_by_year(self, year: int, establishment_id: int):
        return self.transparency_colaborative_repository.get_by_year(year, establishment_id)
    
    def get_by_year_all(self, year: int, establishment_id: int):
        return self.transparency_colaborative_repository.get_by_year_all(year, establishment_id)
    
    def get_months_by_year(self, year: int, establishment_id: int):
        return self.transparency_colaborative_repository.get_months_by_year(year, establishment_id)
    
    def get_all_year_month(self, year: int, month: int):
        return self.transparency_colaborative_repository.get_all_year_month(year, month)    
    
    def approve_transparency_colaborative(self, id):
        return self.transparency_colaborative_repository.approve_transparency_colaborative(id)