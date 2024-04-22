from abc import ABC


class IndicatorsRepositoryEstablishment(ABC):

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


class IndicatorsRepositoryGeneral(ABC):

    def get_days_to_publish(self):
        pass

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
