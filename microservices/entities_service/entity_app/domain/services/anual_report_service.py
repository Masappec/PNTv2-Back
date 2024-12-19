from entity_app.ports.repositories.anual_report_reposity import AnualReportReposity


class AnualReportService:
    def __init__(self, anual_report_repository:AnualReportReposity):
        self.anual_report_repository = anual_report_repository

    def create(self, anual_report: dict):
        return self.anual_report_repository.add(**anual_report)

    def get(self, establishment_id: int, year: int, month: int):
        return self.anual_report_repository.get(establishment_id, year, month)

    def get_all(self):
        return self.anual_report_repository.get_all()

    def update(self, anual_report: dict):
        return self.anual_report_repository.update(**anual_report)

    def delete(self, anual_report_id):
        return self.anual_report_repository.delete(anual_report_id)