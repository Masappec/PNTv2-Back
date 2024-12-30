from datetime import datetime
from entity_app.ports.repositories.anual_report_reposity import AnualReportReposity
import openpyxl
from openpyxl.styles import Alignment
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

    def generate(self, year):
        meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre']
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "T.A-F-C"
        
        columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P']
        widths = [30, 30, 30, 30, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
        for col, width in zip(columns, widths):
            ws.column_dimensions[col].width = width
        
        ws.append([
            "Función a la que pertenece", "Tipo", "Nombre Entidad", "Marco Legal",
            "Enero", "Febreo", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto",
            "Septiembre", "Octubre", "Noviembre", "Diciembre"
        ])
        
        for cell in ws["1:1"]:
            cell.font = openpyxl.styles.Font(bold=True)
            cell.alignment = Alignment(wrap_text=True, vertical='center', horizontal='center')
        
        establishments = EstablishmentExtended.objects.filter(is_active=True).all().order_by('name')
        tc = TransparencyColab.objects.filter(establishment__is_active=True, year=year).all()
        tf = TransparencyFocal.objects.filter(establishment__is_active=True, year=year).all()
        ta = TransparencyActive.objects.filter(establishment__is_active=True, year=year).all()
        solicities = Solicity.objects.filter(deleted=False)
        
        def append_row_without_bold(ws, data):
            ws.append(data)
            ws.cell(row=ws.max_row, column=4).alignment = Alignment(wrap_text=True, vertical='center', horizontal='center')
        
        def append_row(ws, data, bold_col=4):
            ws.append(data)
            ws.cell(row=ws.max_row, column=bold_col).font = openpyxl.styles.Font(bold=True)
            ws.cell(row=ws.max_row, column=bold_col).alignment = Alignment(wrap_text=True, vertical='center', horizontal='center')
        
        def process_transparency(ws, establishment, transparency, legal_text, months):
            list_transparency = {month: False for month in months}
            for t in transparency:
                list_transparency[months[t.month - 1]] = True
            append_row(ws, [
                "FUNCIÓN EJECUTIVA", "Pública", establishment.name, legal_text,
                *['si' if list_transparency[month] else 'no' for month in months]
            ])
        
        for establishment in establishments:
            tc_ = tc.filter(establishment=establishment).all()
            if tc_.exists():
                process_transparency(ws, establishment, tc_, "Art. 4, número 9 T. Colaborativa", meses)
            else:
                append_row(ws, ["FUNCIÓN EJECUTIVA", "Pública", establishment.name, "Art. 4, número 9 T. Colaborativa"] + ['no'] * 12)
            
            tf_ = tf.filter(establishment=establishment).all()
            if tf_.exists():
                process_transparency(ws, establishment, tf_, "Art. 4 número 10 T. Focalizada", meses)
            else:
                append_row(
                    ws, ["FUNCIÓN EJECUTIVA", "Pública", establishment.name, "Art. 4 número 10 T. Focalizada"] + ['no'] * 12)
            
            ta_filtered = ta.filter(establishment=establishment).all()
            list_check_ta = []
            if ta_filtered.exists():
                publications = ta_filtered.filter(numeral__is_default=True).order_by('numeral__name')
                for publication in publications:
                    list_check_ta.append({
                        'numeral': publication.numeral.name,
                        'month': publication.month,
                        'published': publication.published
                    })
            
            numerales_asignados = EstablishmentNumeral.objects.filter(establishment=establishment, numeral__is_default=True).order_by('numeral__name').all()
            start_row = 0
            end_row = 0
            append_row(ws, ["FUNCIÓN EJECUTIVA", "Pública", establishment.name, 'Art. 19 T. Activa'] + [''] * 12)
            
            for index, i in enumerate(numerales_asignados):
                mes_checks = ['si' if any(x['numeral'] == i.numeral.name and x['month'] == _x + 1 and x['published'] for x in list_check_ta) else 'no' for _x in range(12)]
                append_row_without_bold(ws, ["FUNCIÓN EJECUTIVA", "Pública", establishment.name, i.numeral.name.replace('Numeral', ''), *mes_checks])
                
                if index == 0:
                    start_row = ws.max_row
                if index == numerales_asignados.count() - 1:
                    end_row = ws.max_row
            
            if start_row and end_row:
                for col in range(1, 4):
                    ws.merge_cells(start_row=start_row - 1, start_column=col, end_row=end_row, end_column=col)
                    ws.cell(row=start_row - 1, column=col).alignment = Alignment(wrap_text=True, vertical='center', horizontal='center')
            
            ta_filtered_esp = ta.filter(establishment=establishment).all()
            list_check_ta = []
            if ta_filtered_esp.exists():
                publications = ta_filtered_esp.filter(numeral__is_default=False).order_by('numeral__name')
                for publication in publications:
                    list_check_ta.append({
                        'numeral': publication.numeral.name,
                        'month': publication.month,
                        'published': publication.published
                    })
            
            numerales_asignados = EstablishmentNumeral.objects.filter(establishment=establishment, numeral__is_default=False).order_by('numeral__name').all()
            start_row = 0
            end_row = 0
            append_row(ws, ["FUNCIÓN EJECUTIVA", "Pública", establishment.name, 'Obligaciones Específicas'] + [''] * 12)
            
            for index, i in enumerate(numerales_asignados):
                mes_checks = ['si' if any(x['numeral'] == i.numeral.name and x['month'] == _x + 1 and x['published'] for x in list_check_ta) else 'no' for _x in range(12)]
                append_row_without_bold(
                    ws, ["FUNCIÓN EJECUTIVA", "Pública", establishment.name, i.numeral.name.replace('Art.', ''), *mes_checks])
                
                if index == 0:
                    start_row = ws.max_row
                if index == numerales_asignados.count() - 1:
                    end_row = ws.max_row
            
            if start_row and end_row:
                for col in range(1, 4):
                    ws.merge_cells(start_row=start_row - 1, start_column=col, end_row=end_row, end_column=col)
                    ws.cell(row=start_row - 1, column=col).alignment = Alignment(wrap_text=True, vertical='center', horizontal='center')
        
        
        
        
        
            #crea nueva hoja
        ws = wb.create_sheet(title="Pasiva")
        ws.append([
            "Función a la que pertenece", "Tipo", "Nombre Entidad", 
            "No. Solicitud", "Solicitante", "Fecha de envio","Fecha Respuesta",
            "Estado"
        ])
        
        columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
        widths = [30, 30, 30, 30, 30, 30, 30, 30]
        for col, width in zip(columns, widths):
            ws.column_dimensions[col].width = width
        
        for establishment in establishments:
            
            all_solicities = solicities.filter(
                establishment=establishment, date__year=year).all()
            for solicity in all_solicities:
                date = ""
                response = solicity.solicityresponse_set.first()
                if date:
                    date = response.created_at.strftime("%d/%m/%Y")
                solicity_date = solicity.date.strftime("%d/%m/%Y")
                status = Status(solicity.status).label
                append_row_without_bold(ws, [
                    "FUNCIÓN EJECUTIVA", "Pública", solicity.establishment.name,
                    solicity.number_saip, solicity.first_name + " " +
                    solicity.last_name, solicity_date, date, status
                ])
                
        report_name = f'reporte_anual_{year}_{datetime.now().strftime("%d-%m-%Y")}.xlsx'
            
        path = settings.MEDIA_ROOT + f'{report_name}'
        url = settings.MEDIA_URL + f'{report_name}'
        
        wb.save(path)
        return {'path': path, 'url': url}










