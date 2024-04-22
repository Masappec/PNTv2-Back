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
