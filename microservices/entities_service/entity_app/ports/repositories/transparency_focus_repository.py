from abc import ABC, abstractmethod

class TransparencyFocusRepository(ABC):

    @abstractmethod
    def createTransparencyFocus(self, establishment_id, numeral_id, files, month, year, fecha_actual, max_fecha):
        pass

    @abstractmethod
    def getTransparencyFocusUser(self, user_id):
        pass

    @abstractmethod
    def deleteTransparencyFocusUser(self, pk, user_id):
        pass

