
from celery import shared_task
from entity_app.domain.services.anual_report_service import AnualReportService
from entity_app.adapters.impl.anual_report_impl import AnualReportImpl


@shared_task(name='generate_anual_report')
def generate_anual_report(year):
    service = AnualReportService(AnualReportImpl())
    
    return service.generate(year)