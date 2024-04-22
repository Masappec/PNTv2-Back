
from entity_app.ports.repositories.indicators_repository import IndicatorsRepositoryGeneral, IndicatorsRepositoryEstablishment
from entity_app.utils.functions import get_day_for_publish
from datetime import datetime
from entity_app.domain.models.transparency_active import TransparencyActive


class IndicatorsGeneralImpl(IndicatorsRepositoryGeneral):

    def get_days_to_publish(self):
        day_ = get_day_for_publish()

        date = datetime.now()
        day = date.day
        if day < day_:
            days = day_ - day

        else:
            days = 30 - day + day_

        return days

    def get_active_transparency_status(self):

        pass

    def get_active_transparency_history(self):
        pass

    def get_active_transparency_compliance(self):
        pass

    def get_passive_transparency_requests(self):
        pass

    def get_passive_transparency_requests_responded(self):
        pass

    def get_passive_transparency_requests_origin(self):
        pass

    def get_focused_transparency_publications(self):
        pass


class IndicatorsEstablishmentImpl(IndicatorsRepositoryEstablishment):

    def get_days_to_publish(self):
        pass

    def get_active_transparency_status(self, establishment_id):
        pass

    def get_active_transparency_history(self, establishment_id):
        pass

    def get_active_transparency_compliance(self, establishment_id):
        pass

    def get_passive_transparency_requests(self, establishment_id):
        pass

    def get_passive_transparency_requests_responded(self, establishment_id):
        pass

    def get_passive_transparency_requests_origin(self, establishment_id):
        pass

    def get_focused_transparency_publications(self, establishment_id):
        pass
