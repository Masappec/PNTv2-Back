from celery import shared_task
from entity_app.domain.services.anual_report_service import AnualReportService
from entity_app.adapters.impl.anual_report_impl import AnualReportImpl

@shared_task(name='generate_anual_report', bind=True)
def generate_anual_report(self, year):
    service = AnualReportService(AnualReportImpl())
    self.update_state(state='PROGRESS', meta={'progress': 0})
    return service.generate(year, self.update_state)



@shared_task(name='generate_unique_report', bind=True)
def generate_unique_report(self, year, entity_id):
    service = AnualReportService(AnualReportImpl())
    self.update_state(state='PROGRESS', meta={'progress': 0})
    return service.generate_unique(year=year, establishment_id=entity_id, update_state=self.update_state)