from entity_app.domain.models import Solicity, TimeLineSolicity, Extension, \
    Insistency, Status, SolicityResponse
from datetime import datetime
from datetime import timedelta
from entity_app.adapters.messaging.publish import Publisher
from entity_app.adapters.messaging.channels import CHANNEL_SOLICIY
from entity_app.adapters.messaging.events import SOLICITY_FOR_EXPIRED
from entities_service.celery import app


@app.task()
def change_status_solicity():
    # obtener la fecha de hoy

    publiher = Publisher(CHANNEL_SOLICIY)
    print('change_status_solicity')

    date = datetime.now() + timedelta(days=2)
    # obtener las solicitudes que vencen el dos dias
    solicities = Solicity.objects.filter(expiry_date__lte=date,
                                         status__in=[Status.INSISTENCY_SEND, Status.SEND])

    response = SolicityResponse.objects.filter(solicity__in=solicities)
    for solicity in solicities:

        response = response.filter(solicity=solicity)

        if not response.exists():

            publiher.publish({'type': SOLICITY_FOR_EXPIRED,
                             'payload': {
                                 'number_saip': solicity.number_saip,
                                 'date': solicity.date,
                                 'first_name': solicity.first_name,
                                 'last_name': solicity.last_name,
                                 'establishment_id': solicity.establishment.id,
                                 'status': solicity.status,
                                 'user_id': solicity.user_created.id
                             }})

    date = datetime.now()
    solicities = Solicity.objects.filter(expiry_date__lte=date,
                                         status__in=[Status.INSISTENCY_SEND, Status.SEND])

    for solicity in solicities:
        response = response.filter(solicity=solicity)

        if not response.exists():
            if solicity.status == Status.INSISTENCY_SEND:

                solicity.status = Status.INSISTENCY_NO_RESPONSED
                solicity.save()
            else:

                solicity.status = Status.NO_RESPONSED
                solicity.save()
