


from app_admin.ports.repositories.pedagogy_area_repository import PedagogyAreaRepository


class PedagogyAreaService:
    
    
    def __init__(self,respository:PedagogyAreaRepository):
        self.__repository = respository
        
        
    def create(self, faq, tutorial, normative, user_id):
        
        
        return self.__repository.create_area(faq, tutorial, normative, user_id)
    
    
    def select_area(self):
        return self.__repository.select_area()