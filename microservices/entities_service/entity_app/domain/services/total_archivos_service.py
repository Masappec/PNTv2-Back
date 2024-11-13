from entity_app.ports.repositories.archivo_transparencia_repository import ArchivoTransparenciaRepository

class TotalArchivosService:
    def __init__(self):
        self.archivo_repo = ArchivoTransparenciaRepository()

    def obtener_totales(self):
        return self.archivo_repo.contar_archivos_por_tipo()
