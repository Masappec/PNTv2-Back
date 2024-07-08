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

    @abstractmethod
    def update_transparency_colaborative(self, pk, user_id, newfiles):
        pass

    @abstractmethod
    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        pass

    @abstractmethod
    def get_by_year(self, year: int, establishment_id: int):
        pass