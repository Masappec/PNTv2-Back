from abc import ABC, abstractmethod


class PedagogyAreaRepository(ABC):
    
    
    @abstractmethod
    def create_area(self, faq, tutorial, normative, user_id):
        """
            Crea un area de pedagogia con los datos recibidos

        Args:
            faq (list(
                dict(
                    question (_type_): _description_,
                    answer (_type_): _description_
                )
                
                )): lista de preguntas frecuentes
                
            tutorial (list(
                dict(
                    title (_type_): _description_,
                    description (_type_): _description_,
                    url (_type_): _description_
                    is_active (_type_): _description_
                )
                
                )): lista de tutoriales
            normative (list(
                dict(
                    title (_type_): _description_,
                    description (_type_): _description_,
                    url (_type_): _description_
                    is_active (_type_): _description_
                )
                
                )): lista de normativas
            user_id (int): id del usuario que crea el area
        """
        pass
    
    
    @abstractmethod
    def select_area(self):
        """
            Selecciona un area de pedagogia

        Returns:
            dict: area de pedagogia seleccionada
        """
        pass