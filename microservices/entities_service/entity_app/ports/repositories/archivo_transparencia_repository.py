from entity_app.adapters.impl import publication_impl

class ArchivoTransparenciaRepository:
    def contar_archivos_por_tipo(self):
        # Realizar la consulta a la base de datos para obtener el conteo por tipo
        totales = (
            PublicationImpl.ArchivoTransparencia.objects
            .values('tipo_transparencia')
            .annotate(total=Count('id'))
        )
        return {
            "activa": next((item['total'] for item in totales if item['tipo_transparencia'] == 'activa'), 0),
            "focalizada": next((item['total'] for item in totales if item['tipo_transparencia'] == 'focalizada'), 0),
            "colaborativa": next((item['total'] for item in totales if item['tipo_transparencia'] == 'colaborativa'), 0),
        }
