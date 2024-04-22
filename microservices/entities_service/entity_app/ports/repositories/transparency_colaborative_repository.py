from abc import ABC, abstractmethod


class TransparencyColaborativeRepository(ABC):

    @abstractmethod
    def createTransparencyColaborative(self, establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha):
        pass

    @abstractmethod
    def getTransparencyColaborativeUser(self, user_id):
        pass

    @abstractmethod
    def deleteTransparencyColaborativeUser(self, pk, user_id):
        pass

    def update_transparency_colaborative(self, pk, user_id, newfiles):
        pass
