import json

from app_admin.ports.repositories.frequently_asked_questions_repository import FrequentlyAskedQuestionsRepository


class FrequentlyAskedQuestionsService:
    def __init__(self, frequently: FrequentlyAskedQuestionsRepository):
        """
                The constructor for the UserService class.

                Args:
                    frequently (FrequentlyAskedQuestionsRepository): The frequently parameter is an instance of the
                    FrequentlyAskedQuestionsRepository class that will be used to retrieve,
                    create FrequentlyAskedQuestions objects.
                """
        self.frequently = frequently

    def register_faq(self, frequentlyAskedQuestions: dict):
        """
        la funcion registra preguntas y respuestas.
        tomando datos de la vista de registro de la aplicacion web

        Args:
            frequentlyAskedQuestions (dict): el parametro user es un diccionario que contiene los datos de las preguntas a registrar
            frequentlyAskedQuestions = {
                "question_text": "string",
                "answer_text": "string",
                "user_insert": "int"
            }

        Returns:
            User: Retorna un objeto PreguntasRespuestas con los datos del usuario registrado
        """
        frequentlyAskedQuestions['question_text'] = frequentlyAskedQuestions['question_text']
        frequentlyAskedQuestions['answer_text'] = frequentlyAskedQuestions['answer_text']
        frequentlyAskedQuestions['user_insert'] = frequentlyAskedQuestions['user_insert']

        data = self.frequently.register_faq(frequentlyAskedQuestions)
        return json.loads(data)

    def get_all_frequently_asked_questions(self):
        """
        Get a list of frequently_asked_questions.

        Returns:
            FrequentlyAskedQuestions: The frequently_asked_questions object.
        """
        frequently = self.frequently.get_all_frequently_asked_questions()
        return frequently

    def get_frequently_asked_questions_by_question(self, question: str):
        """
        Obtienes listado de preguntas

        Args:
            question (str): The question of the question to retrieve.

        Returns:
            FrequentlyAskedQuestions: The frequentlyAskedQuestions object.
        """
        return self.frequently.get_frequently_asked_questions_by_question(question)
