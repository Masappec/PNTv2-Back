

from entity_app.domain.models.base_model import BaseModel
from django.db import models

class AnualReport(BaseModel):
    establishment_id = models.ForeignKey('EstablishmentExtended', on_delete=models.CASCADE,
                                         related_name='anual_report_establishment')
    year = models.IntegerField()
    month = models.IntegerField()

    # ARTICULO 10
    have_public_records = models.BooleanField()
    norme_archive_utility = models.CharField(max_length=255)
    comment_aclaration = models.TextField()

    # ARTICULO 11
    # Ingrese el número de solicitudes de acceso a la información 
    # pública que su entidad recibió y gestionó en el período enero-diciembre

    total_saip = models.IntegerField()
    did_you_entity_receive = models.BooleanField()
    total_saip_in_portal = models.IntegerField()
    total_saip_no_portal = models.IntegerField()
    description_rason_no_portal = models.TextField()
    
    # ¿Las solicitudes de acceso a la información pública que NO fueron registradas en el
    # Portal Nacional de Transparencia, fueron respondidas?
    total_no_registered = models.IntegerField()
    comment_aclaration_no_registered = models.TextField()
    

    # Artículo 11
    # Informe semestral actualizado sobre el listado 
    # índice de información reservada
    reserve_information = models.BooleanField()
    # En caso de seleccionar Sí, debe completar los siguientes campos:
    number_of_reserves = models.IntegerField()
    number_of_confidential = models.IntegerField()
    number_of_secret = models.IntegerField()
    number_of_secretism = models.IntegerField()
    
    # El índice de la información clasificada como reservada, 
    # detallando la fecha de la resolución de clasificación 
    # de la reserva y el período de vigencia de la misma

    #listado
    information_classified = models.ManyToManyField('IndexInformationClassified', blank=True, related_name='anual_report_information_classified')


    # Artículo 40
    #Gestión Oficiosa

    #¿Alguna persona que solicitó información indicó que la recibida no era de calidad, 
    # o existió ambigüedad en el manejo de la información registrada en el Portal Nacional de Transparencia
    # o sobre la información que se difunde en la propia institución, y resolvió solicitar la corrección en 
    # la difusión de la información
    # o alguna persona solicitó la intervención del Defensor del Pueblo para que se corrija y 
    # se brinde mayor claridad y sistematización en la organización de la información ?

    have_quality_problems = models.BooleanField()
    total_quality_problems = models.IntegerField()
    description_quality_problems = models.TextField()
    

    # Artículo 42 de la LOTAIP
    #Sanciones administrativas

    #¿Personas servidoras públicas de su entidad o personas del sector privado han recibido
    # sanciones por omisión o negativa en el acceso a la información pública?
    
    have_sanctions = models.BooleanField()
    total_organic_law_public_service = models.IntegerField()
    description_organic_law_public_service = models.TextField()
    total_organic_law_contraloria = models.IntegerField()
    description_organic_law_contraloria = models.TextField()
    total_organic_law_national_system = models.IntegerField()
    description_organic_law_national_system = models.TextField()
    total_organic_law_citizen_participation = models.IntegerField()
    description_organic_law_citizen_participation = models.TextField()
    

    # Disposición transitoria séptima
    # su entidad implementó programas de difución
    implemented_programs = models.BooleanField()
    total_programs = models.IntegerField()
    description_programs = models.TextField()
    

    # Disposición transitoria octava
    # ¿Sí su entidad es un establecimiento educativo público 
    # o privado, desarrolló actividades y programas de promoción del derecho de acceso 
    # a la información pública, sus garantías y referente a la 
    # transparencia sus garantías y referente a la transparencia colaborativa?
    have_activities = models.BooleanField()
    total_activities = models.IntegerField()
    description_activities = models.TextField()
    
    objects = models.Manager()
    


class IndexInformationClassified(BaseModel):
    topic = models.CharField(max_length=255)
    legal_basis = models.CharField(max_length=255)
    classification_date = models.DateField()
    period_of_validity = models.CharField(max_length=255)
    amplation_effectuation = models.BooleanField()
    ampliation_description = models.TextField()
    ampliation_date = models.DateField()
    ampliation_period_of_validity = models.CharField(max_length=255)
    anual_report = models.ForeignKey('AnualReport', on_delete=models.CASCADE)
    objects = models.Manager()
