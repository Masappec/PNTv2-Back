from rest_framework_simplejwt.authentication import JWTAuthentication

from app_admin.domain.models import FrequentlyAskedQuestions
from app_admin.ports.repositories.frequently_asked_questions_repository import FrequentlyAskedQuestionsRepository


class FrequentlyAskedQuestionsImpl(FrequentlyAskedQuestionsRepository):
    """
    The FrequentlyAskedQuestionsImpl class implements the FrequentlyAskedQuestionsRepository abstract base class.

    Args:
        FrequentlyAskedQuestionsRepository (FrequentlyAskedQuestionsRepository): The FrequentlyAskedQuestionsRepository class is an abstract
        base class that defines methods for retrieving, creating FrequentlyAskedQuestions objects.

    """

    def __init__(self):
        """
        The constructor for the UserRepositoryImpl class.
        """
        self.jwt_authentication = JWTAuthentication()

    def register_faq(self, frequentlyAskedQuestions: dict):
        return FrequentlyAskedQuestions.register_faq(**frequentlyAskedQuestions)

    def get_all_frequently_asked_questions(self):
        """
        Get a list of frequentlyAskedQuestions.

        Returns:
            FrequentlyAskedQuestions: The frequentlyAskedQuestions object.
        """
        return FrequentlyAskedQuestions.objects.all()

    def get_frequently_asked_questions_by_question(self, question: str):
        """
        Obtienes listado de preguntas

        Args:
            question (str): The question of the question to retrieve.

        Returns:
            FrequentlyAskedQuestions: The frequentlyAskedQuestions object.
        """
        return FrequentlyAskedQuestions.objects.get(question=question)
