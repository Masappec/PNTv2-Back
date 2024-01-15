from django.db import models
from .base_model import BaseModel
from django.db import connection
import psycopg2


class PedagogyArea(BaseModel):
    published = models.BooleanField(default=False)

    class Meta:

        verbose_name = 'Area de Pedagogia'
        verbose_name_plural = 'Areas de Pedagogia'

    @staticmethod
    def create_pedagogy_area(asked_questions, tutorial_videos, normative_documents, user_id):
        '''
            Metodo para crear un area de pedagogia

            Args:
                asked_questions (list): Lista de preguntas frecuentes 
                {
                    "question": "Pregunta",
                    "answer": "Respuesta"
                },

                tutorial_videos (list): Lista de videos tutoriales
                {
                    "title": "Titulo",
                    "description": "Descripcion",
                    "url": "URL"
                },

                normative_documents (list): Lista de documentos normativos
                {
                    "title": "Titulo",
                    "description": "Descripcion",
                    "url": "URL"
                },
                user_id (int): Id del usuario que crea el area de pedagogia
            Returns:
                {
                    'pedagogy_area: {
                        'id': int,
                        'created_at': datetime,
                        'updated_at': datetime,
                        'deleted': bool,
                        'deleted_at': datetime,
                        'user_created': int,
                        'user_updated': int,
                        'user_deleted': int,
                        'ip': str,
                        'published': bool

                    },
                    'faq': [
                        {
                            'id': int,
                            'created_at': datetime,
                            'updated_at': datetime,
                            'deleted': bool,
                            'deleted_at': datetime,
                            'user_created': int,
                            'user_updated': int,
                            'user_deleted': int,
                            'ip': str,
                            'question': str,
                            'answer': str,
                            'pedagogy_area': int,
                            'is_active': bool
                        }
                    ],
                    'tutorial_videos': [
                        {
                            'id': int,
                            'created_at': datetime,
                            'updated_at': datetime,
                            'deleted': bool,
                            'deleted_at': datetime,
                            'user_created': int,
                            'user_updated': int,
                            'user_deleted': int,
                            'ip': str,
                            'title': str,
                            'description': str,
                            'url': str,
                            'pedagogy_area': int,
                            'is_active': bool
                        }
                    ],
                    'normative': [
                        {
                            'id': int,
                            'created_at': datetime,
                            'updated_at': datetime,
                            'deleted': bool,
                            'deleted_at': datetime,
                            'user_created': int,
                            'user_updated': int,
                            'user_deleted': int,
                            'ip': str,
                            'title': str,
                            'description': str,
                            'url': str,
                            'pedagogy_area': int,
                            'is_active': bool
                        }
                    ]
                }
        '''
        try:
            questions = [
                (question['question'], question['answer']) for question in asked_questions
            ]
            videos = [
                (video['title'], video['description'], video['url'], True)for video in tutorial_videos
            ]
            documents = [
                (document['title'], document['description'], document['url'], True) for document in normative_documents
            ]

            with connection.cursor() as cursor:
                cursor.execute('''SELECT admin_register_pedagogy_area(
                    %s::ASKED_QUESTION[], 
                    %s::TUTORIAL[], 
                    %s::NORMATIVE[], 
                    %s
                )''', (
                    questions, videos, documents, user_id

                ))
                row = cursor.fetchone()
                return row[0]
        except psycopg2.Error as e:
            raise e
        finally:
            cursor.close()
            connection.close()

    
    @staticmethod
    def admin_select_pedagogy_area():
        '''
            Metodo para seleccionar un area de pedagogia

            Returns:
                {
                    'pedagogy_area: {
                        'id': int,
                        'created_at': datetime,
                        'updated_at': datetime,
                        'deleted': bool,
                        'deleted_at': datetime,
                        'user_created': int,
                        'user_updated': int,
                        'user_deleted': int,
                        'ip': str,
                        'published': bool

                    },
                    'faq': [
                        {
                            'id': int,
                            'created_at': datetime,
                            'updated_at': datetime,
                            'deleted': bool,
                            'deleted_at': datetime,
                            'user_created': int,
                            'user_updated': int,
                            'user_deleted': int,
                            'ip': str,
                            'question': str,
                            'answer': str,
                            'pedagogy_area': int,
                            'is_active': bool
                        }
                    ],
                    'tutorial_videos': [
                        {
                            'id': int,
                            'created_at': datetime,
                            'updated_at': datetime,
                            'deleted': bool,
                            'deleted_at': datetime,
                            'user_created': int,
                            'user_updated': int,
                            'user_deleted': int,
                            'ip': str,
                            'title': str,
                            'description': str,
                            'url': str,
                            'pedagogy_area': int,
                            'is_active': bool
                        }
                    ],
                    'normative': [
                        {
                            'id': int,
                            'created_at': datetime,
                            'updated_at': datetime,
                            'deleted': bool,
                            'deleted_at': datetime,
                            'user_created': int,
                            'user_updated': int,
                            'user_deleted': int,
                            'ip': str,
                            'title': str,
                            'description': str,
                            'url': str,
                            'pedagogy_area': int,
                            'is_active': bool
                        }
                    ]
                }
        '''
        try:
            with connection.cursor() as cursor:
                cursor.execute('''SELECT admin_select_pedagogy_area()''')
                row = cursor.fetchone()
                return row[0]
        except psycopg2.Error as e:
            raise e
        finally:
            cursor.close()
            connection.close()