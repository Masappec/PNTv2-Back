

import json
from app_admin.domain.models import PedagogyArea
from app_admin.ports.repositories.pedagogy_area_repository import PedagogyAreaRepository


class PedagogyAreaImpl(PedagogyAreaRepository):

    def create_area(self, asked_questions, tutorial_videos, normative_documents, user_id):
        data = PedagogyArea.create_pedagogy_area(
            normative_documents=normative_documents,
            asked_questions=asked_questions,
            tutorial_videos=tutorial_videos,
            user_id=user_id
        )
        
        #string to json
        data = json.loads(data)
        
        return data

    def select_area(self):
        data = PedagogyArea.admin_select_pedagogy_area()
        
        #string to json
        data = json.loads(data)
        
        return data
