from openpyxl import Workbook
from django.db.models import Prefetch
from datetime import datetime
from entity_app.ports.repositories.anual_report_reposity import AnualReportReposity
import openpyxl
from openpyxl.styles import Alignment, Font
from entity_app.domain.models.establishment import EstablishmentExtended
from entity_app.domain.models.transparecy_colab import TransparencyColab
from entity_app.domain.models.transparecy_foc import TransparencyFocal
from entity_app.domain.models.transparency_active import EstablishmentNumeral, TransparencyActive
from entity_app.domain.models.solicity import Solicity, Status
from django.conf import settings
class AnualReportService:
    def __init__(self, anual_report_repository: AnualReportReposity):
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

    def generate(self, year, update_state):
        meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
        establishments = EstablishmentExtended.objects.filter(is_active=True).prefetch_related(
            Prefetch('transparency_colab', queryset=TransparencyColab.objects.filter(
                year=year), to_attr='tc'),
            Prefetch('transparency_focal', queryset=TransparencyFocal.objects.filter(
                year=year), to_attr='tf'),
            Prefetch('transparency_active', queryset=TransparencyActive.objects.filter(
                year=year), to_attr='ta')
            
        ).order_by('name')[:100]

        solicities = Solicity.objects.filter(deleted=False)

        # Crear libro de Excel
        wb = Workbook()
        ws = wb.active
        ws.title = "T.A-F-C"

        # Configuración de columnas y anchos
        columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G',
                'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P']
        widths = [30, 30, 30, 30, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
        for col, width in zip(columns, widths):
            ws.column_dimensions[col].width = width

        # Encabezados de la hoja
        ws.append([
            "Función a la que pertenece", "Tipo", "Nombre Entidad", "Marco Legal",
            "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto",
            "Septiembre", "Octubre", "Noviembre", "Diciembre"
        ])

        # Estilo de las celdas
        for cell in ws["1:1"]:
            cell.font = Font(bold=True)
            cell.alignment = Alignment(
                wrap_text=True, vertical='center', horizontal='center')

        # Funciones auxiliares


        def append_row(ws, data, bold_col=4):
            ws.append(data)
            ws.cell(row=ws.max_row, column=bold_col).font = Font(bold=True)
            ws.cell(row=ws.max_row, column=bold_col).alignment = Alignment(
                wrap_text=True, vertical='center', horizontal='center')


        def append_row_without_bold(ws, data):
            ws.append(data)
            ws.cell(row=ws.max_row, column=4).alignment = Alignment(
                wrap_text=True, vertical='center', horizontal='center')


        def process_transparency(ws, establishment, transparency, legal_text, months):
            list_transparency = {month: False for month in months}
            for t in transparency:
                list_transparency[months[t.month]] = True
            append_row(ws, [
                "FUNCIÓN EJECUTIVA", "Pública", establishment.name, legal_text,
                *['si' if list_transparency[month] else 'no' for month in months]
            ])


        # Procesar datos de transparencia para cada establecimiento
        for number, establishment in enumerate(establishments):
            # Transparencia colaborativa
            progress = (number+1) / len(establishments) * 100
            progress = round(progress, 2)
            update_state(state='PROGRESS', meta={
                        'progress': progress,
                           'message': f"Procesando publicaciones de transparencia... Obteniendo información {number+1}/{len(establishments)} entidades... | Creando parte 1/2"

                        })
            if len(establishment.tc) > 0:
                process_transparency(ws, establishment, establishment.tc,
                                    "Art. 4, número 9 T. Colaborativa", meses)
            else:
                append_row(ws, ["FUNCIÓN EJECUTIVA", "Pública", establishment.name,
                        "Art. 4, número 9 T. Colaborativa"] + ['no'] * 12)

            # Transparencia focalizada
            if len(establishment.tf) > 0:
                process_transparency(ws, establishment, establishment.tf,
                                    "Art. 4 número 10 T. Focalizada", meses)
            else:
                append_row(ws, ["FUNCIÓN EJECUTIVA", "Pública", establishment.name,
                        "Art. 4 número 10 T. Focalizada"] + ['no'] * 12)

            # Transparencia activa
            list_check_ta = []
            if len(establishment.ta) > 0:
                
                publications = [
                    ta for ta in establishment.ta if ta.numeral.is_default]
                publications = sorted(
                    publications, key=lambda x: x.numeral.name)
                for publication in publications:
                    list_check_ta.append({
                        'numeral': publication.numeral.name,
                        'month': publication.month,
                        'published': publication.published
                    })

            numerales_asignados = EstablishmentNumeral.objects.filter(
                establishment=establishment, numeral__is_default=True).order_by('numeral__name')
            append_row(ws, ["FUNCIÓN EJECUTIVA", "Pública",
                    establishment.name, 'Art. 19 T. Activa'] + [''] * 12)

            # Numerales asignados para Art. 19 T. Activa
            for i in numerales_asignados:
                mes_checks = ['si' if any(x['numeral'] == i.numeral.name and x['month'] == _x +
                                        1 and x['published'] for x in list_check_ta) else 'no' for _x in range(12)]
                append_row_without_bold(ws, ["FUNCIÓN EJECUTIVA", "Pública",
                                        establishment.name, i.numeral.name.replace('Numeral', ''), *mes_checks])

        # Crear nueva hoja "Pasiva"
        ws = wb.create_sheet(title="Pasiva")
        ws.append([
            "Función a la que pertenece", "Tipo", "Nombre Entidad",
            "No. Solicitud", "Solicitante", "Fecha de envio", "Fecha Respuesta",
            "Estado"
        ])

        columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
        widths = [30, 30, 30, 30, 30, 30, 30, 30]
        for col, width in zip(columns, widths):
            ws.column_dimensions[col].width = width

        # Procesar solicitudes
        for number, establishment in enumerate(establishments):
            progress_calculate = (number+1)
            progress = progress_calculate / len(establishments) * 100
            progress = round(progress, 2)
            
            update_state(state='PROGRESS', meta={
                         'progress': progress, 
                         'message': f"Procesando solicitudes... Obteniendo información {progress_calculate}/{len(establishments)} entidades... | Creando parte 2/2"
                         })
            all_solicities = solicities.filter(
                establishment=establishment, date__year=year)
            for solicity in all_solicities:
                response = solicity.solicityresponse_set.first()
                date = response.created_at.strftime("%d/%m/%Y") if response else ""
                solicity_date = solicity.date.strftime("%d/%m/%Y")
                status = Status(solicity.status).label
                append_row_without_bold(ws, [
                    "FUNCIÓN EJECUTIVA", "Pública", solicity.establishment.name,
                    solicity.number_saip, f"{solicity.first_name} {
                        solicity.last_name}", solicity_date, date, status
                ])

        # Guardar archivo
        report_name = f'reporte_anual_{year}_{
            datetime.now().strftime("%d-%m-%Y")}.xlsx'
        path = settings.MEDIA_ROOT + f'{report_name}'
        url = settings.MEDIA_URL + f'{report_name}'

        wb.save(path)
        return {'path': path, 'url': url}











