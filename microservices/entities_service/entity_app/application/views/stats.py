from entity_app.domain.models import Solicity,Status
from rest_framework.views import APIView
from datetime import datetime
from rest_framework.response import Response
from django.contrib.auth.models import User
class StatsCitizen(APIView):
    
    permission_classes = []
    def get(self, request):
        
        year = request.query_params.get('year', None)
        establishment = request.query_params.get('establishment_id', None)
            
        
        data = {
            "total": 0,
            "responsed": None,
            "not_responsed": None,
            "total_not_responsed": None,
            "total_responsed": None,
            "users":{
                "active": 0,
                "inactive": 0
            }
        }
        all = None
        if establishment:
            all = Solicity.objects.filter(establishment_id=establishment)
            total_responsed = Solicity.objects.filter(status__in=[Status.RESPONSED,
                                                     Status.INSISTENCY_RESPONSED,
                                                     Status.INFORMAL_MANAGMENT_RESPONSED], establishment_id=establishment)

            total_not_responsed = Solicity.objects.filter(establishment_id=establishment).exclude(status__in=[Status.RESPONSED,
                                                        Status.INSISTENCY_RESPONSED,
                                                        Status.INFORMAL_MANAGMENT_RESPONSED])
        else:
            
            all = Solicity.objects.all()
            total_responsed = Solicity.objects.filter(status__in=[Status.RESPONSED,
                                                     Status.INSISTENCY_RESPONSED,
                                                     Status.INFORMAL_MANAGMENT_RESPONSED])

            total_not_responsed = Solicity.objects.exclude(status__in=[Status.RESPONSED,
                                                        Status.INSISTENCY_RESPONSED,
                                                        Status.INFORMAL_MANAGMENT_RESPONSED])
        if year:
            all = all.filter(date__year=year)
            total_not_responsed = total_not_responsed.filter(date__year=year)
            total_responsed = total_responsed.filter(date__year=year)
            
        
        
        total_not_responsed = total_not_responsed.count()
        total_responsed = total_responsed.count()
        #seccionarlas por mes
        months = []
        months_noresponsed = []
        for i in range(1,13):
            if year:
                month = all.filter(status__in=[Status.RESPONSED,
                                               Status.INSISTENCY_RESPONSED,
                                               Status.INFORMAL_MANAGMENT_RESPONSED], date__month=i, date__year=year).count()
                no_responsed = all.filter(date__month=i, date__year=year).exclude(status__in=[Status.RESPONSED,
                                                                                                 Status.INSISTENCY_RESPONSED,
                                                                                                 Status.INFORMAL_MANAGMENT_RESPONSED
                                                                                                 ]).count()
            else:
                month = all.filter(status__in=[Status.RESPONSED,
                                               Status.INSISTENCY_RESPONSED,
                                               Status.INFORMAL_MANAGMENT_RESPONSED], date__month=i).count()
                no_responsed = all.filter(date__month=i).exclude(status__in=[Status.RESPONSED,
                                                                             Status.INSISTENCY_RESPONSED,
                                                                             Status.INFORMAL_MANAGMENT_RESPONSED
                                                                             ]).count()
                
            
            months.append(month)
            #no sea igual a respondido
            
            
            
            months_noresponsed.append(no_responsed)
        
        users = User.objects.all()
        
        total_users_active = users.filter(is_active=True).count()
        total_users_inactive = users.filter(is_active=False).count()
            
        
        data["responsed"] = months
        data["not_responsed"] = months_noresponsed
        data["total_not_responsed"] = total_not_responsed
        data["total_responsed"] = total_responsed
        data["users"]["active"] = total_users_active
        data["users"]["inactive"] = total_users_inactive
        data["total"] = all.count()
        
        return Response(data, status=200)
        
        
        
        
            
            
        
        
        