from abc import ABC, abstractmethod

from app_admin.domain.models import FrequentlyAskedQuestions

class FrequentlyAskedQuestionsRepository(ABC):

    @abstractmethod
    def get_all_frequently_asked_questions(self):
        pass

    @abstractmethod
    def get_frequently_asked_questions_by_question(self, question: str):
        pass

    @abstractmethod
    def register_faq(self, frequentlyAskedQuestions: dict):
        """
        The function `register_faq` is an abstract method that takes a dictionary `frequentlyAskedQuestions` as input and does
        not have an implementation.

        :param frequentlyAskedQuestions: A dictionary representing the FrequentlyAskedQuestions data
        :type frequentlyAskedQuestions: dict
        """
        pass