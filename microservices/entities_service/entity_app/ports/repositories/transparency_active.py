from abc import ABC, abstractmethod


class TransparencyActiveRepository(ABC):

    @abstractmethod
    def get_by_year_month(self, year: int, month: int, establishment_id: int):
        pass

    @abstractmethod
    def get_by_numeral(self, numeral_id: int, month: int, year: int, establishment_id: int):
        pass

    @abstractmethod
    def get_by_year(self, year: int, establishment_id: int):
        pass

    @abstractmethod
    def get_search(self, search: str, establishment_id: int):
        pass

    def get_by_id(self, id: int):
        pass


    @abstractmethod
    def get_months_by_year(self, year: int, establishment_id: int):
        pass
    
    @abstractmethod
    def get_all_year_month(self,year:int,mont:int):
        pass
    
    