from entity_app.domain.models import Solicity, TimeLineSolicity, Extension, \
    Insistency, Status, SolicityResponse
from datetime import datetime,date
from datetime import timedelta
from entity_app.adapters.messaging.publish import Publisher
from entity_app.adapters.messaging.channels import CHANNEL_SOLICIY
from entity_app.adapters.messaging.events import SOLICITY_FOR_EXPIRED
from entities_service.celery import app
from entity_app.domain.models.establishment import UserEstablishmentExtended
from entity_app.domain.models.solicity import TypeStages
from entity_app.utils.functions import get_timedelta_for_expired
from django.db.models import Q
from django.utils import timezone

@app.task()
def change_status_solicity():

    # obtener la fecha de hoy
    now = timezone.now()
    publiher = Publisher(CHANNEL_SOLICIY)
    date_ = datetime.now() + timedelta(minutes=15)
    # obtener las solicitudes que vencen el dos dias
    solicities = Solicity.objects.filter(expiry_date__lte=date_,
                                         status__in=[Status.INSISTENCY_SEND, 
                                                     Status.SEND, 
                                                     Status.INFORMAL_MANAGMENT_SEND],
                                         date_mail_send__isnull=True)
    response = SolicityResponse.objects.filter(solicity__in=solicities)
    es = UserEstablishmentExtended.objects.all()
    for solicity in solicities:

        response = response.filter(solicity=solicity)

        if not response.exists():
            solicity.date_mail_send = datetime.now()
            solicity.save()
            publiher.publish({'type': SOLICITY_FOR_EXPIRED,
                             'payload': {
                                 'number_saip': solicity.number_saip,
                                 'date': solicity.date.strftime('%Y-%m-%d'),
                                 'first_name': solicity.first_name,
                                 'last_name': solicity.last_name,
                                 'establishment_id': solicity.establishment.id,
                                 'status': solicity.status,
                                 'user_id': solicity.user_created.id,
                                 'solicity_id': solicity.id,
                                 'email': [es.user.email for es in es.filter(establishment_id=solicity.establishment.id)]
                             }})

    
    
    
    

    solicities = Solicity.objects.filter(expiry_date__lte=datetime.now(),
                                         status__in=[Status.INSISTENCY_SEND, Status.SEND,
                                                     Status.INFORMAL_MANAGMENT_SEND,Status.PRORROGA])




    for solicity in solicities:
        response = response.filter(solicity=solicity)

       

        if solicity.status == Status.SEND:
            solicity.status = Status.NO_RESPONSED
            solicity.date_mail_send = None
            solicity.save()
            TimeLineSolicity.objects.create(
                solicity=solicity, status=Status.NO_RESPONSED)
        elif solicity.status == Status.INSISTENCY_SEND:
            solicity.status = Status.INSISTENCY_NO_RESPONSED
            solicity.date_mail_send = None

            solicity.save()
            TimeLineSolicity.objects.create(
                solicity=solicity, status=Status.INSISTENCY_NO_RESPONSED)
            
        elif solicity.status == Status.PRORROGA:
            solicity.status = Status.NO_RESPONSED
            solicity.date_mail_send = None

            solicity.save()
            TimeLineSolicity.objects.create(
                solicity=solicity, status=Status.NO_RESPONSED)
        elif solicity.status == Status.INFORMAL_MANAGMENT_SEND:
            solicity.status = Status.INFORMAL_MANAGMENT_NO_RESPONSED
            solicity.date_mail_send = None

            solicity.save()
            TimeLineSolicity.objects.create(
                solicity=solicity, status=Status.INFORMAL_MANAGMENT_NO_RESPONSED)
            
        elif solicity.status == Status.INFORMAL_MANAGMENT_NO_RESPONSED:
            solicity.status = Status.FINISHED_WITHOUT_RESPONSE
            solicity.date_mail_send = None

            solicity.save()
            TimeLineSolicity.objects.create(
                solicity=solicity, status=Status.FINISHED_WITHOUT_RESPONSE)
        elif solicity.status == Status.INFORMAL_MANAGMENT_RESPONSED:

            solicity.status = Status.FINISHED
            solicity.save()
            TimeLineSolicity.objects.create(
                solicity=solicity, status=Status.FINISHED)
                

    solicities_all = Solicity.objects.filter(status__in=[Status.PERIOD_INFORMAL_MANAGEMENT,
                                                        Status.INSISTENCY_PERIOD,
                                                        Status.PRORROGA])
    
    timelines = TimeLineSolicity.objects.filter(solicity__in=solicities_all)
    insistencies = Insistency.objects.filter(solicity__in=solicities_all)
    prorrogas = Extension.objects.filter(solicity__in=solicities_all)
    
    for i in solicities_all:
        
        if i.status == Status.PERIOD_INFORMAL_MANAGEMENT:
            timeSolicity = timelines.filter(solicity=i,status=Status.PERIOD_INFORMAL_MANAGEMENT).first()
                            
            timeant = timelines.filter(solicity=i).exclude(
                status=Status.PERIOD_INFORMAL_MANAGEMENT).last()
            if timeSolicity:
                #verificar si ya pasaron 15 minutos desde que se creo
                created_at = timezone.localtime(timeSolicity.created_at)

                # verificar si ya pasaron 15 minutos desde que se creo
                if now > created_at + timedelta(minutes=2):

                    
                    insitencia = insistencies.filter(solicity=i)\
                        .exclude(user_id=i.user_created).first()
                    
                    print("INSISTENCIA",insitencia)
                        
                    if not insitencia:
                        i.status = timeant.status
                        i.save()
                        timeSolicity.delete()
                        
        if i.status == Status.INSISTENCY_PERIOD:
            timeSolicity = timelines.filter(solicity=i,status=Status.INSISTENCY_PERIOD).first()
            timeant = timelines.filter(solicity=i).exclude(status=Status.INSISTENCY_PERIOD).last()
            if timeSolicity:

                created_at = timezone.localtime(timeSolicity.created_at)

                # verificar si ya pasaron 15 minutos desde que se creo
                if now > created_at + timedelta(minutes=2):

                    insitencia = insistencies.filter(solicity=i, status=Status.SEND)\
                        .exclude(~Q(user_id=i.user_created)).first()
                    if not insitencia:
                        print("INSISTENCIA",insitencia)
                        i.status = timeant.status
                        i.save()
                        timeSolicity.delete()
                        
                        
        if i.status == Status.PRORROGA:
            timeSolicity = timelines.filter(solicity=i,status=Status.PRORROGA).first()
            timeant = timelines.filter(solicity=i).exclude(
                status=Status.PRORROGA).last()
            if timeSolicity:
                #verificar si ya pasaron 15 minutos desde que se creo
                created_at = timezone.localtime(timeSolicity.created_at)

                # verificar si ya pasaron 15 minutos desde que se creo
                if now > created_at + timedelta(minutes=2):

                    
                    pror = prorrogas.filter(solicity=i).first()
                    print("PRORROGA",pror)
                    if not pror:
                        i.status = timeant.status
                        i.save()
                        timeSolicity.delete()
            
            
            