from entity_app.domain.models import Solicity,Status
from rest_framework.views import APIView
from datetime import datetime
from rest_framework.response import Response

class StatsCitizen(APIView):
    
    def get(self, request):
        
        year = request.query_params.get('year', None)
        establishment = request.query_params.get('establishment', None)
        if not year:
            year = datetime.now().year
            
        
        data = {
            "total": Solicity.objects.count(),
            "responsed": None,
            "not_responsed": None,
            "total_not_responsed": None,
            "total_responsed": None,
            "users":None
        }
        all = None
        if establishment:
            all = Solicity.objects.filter(created_at__year=year,
                                          establishment=establishment)
        else:
            all = Solicity.objects.filter(created_at__year=year)
        
        #seccionarlas por mes
        months = []
        months_noresponsed = []
        total_responsed = all.filter(status=Status.RESPONSED).count()
        total_not_responsed = all.filter(status__ne=Status.RESPONSED).count()
        for i in range(1,13):
            month = all.filter(status=Status.RESPONSED,
                               created_at__month=i).count()
            months.append(month)
            #no sea igual a respondido
            no_responsed = all.filter(status__ne=Status.RESPONSED,
                                     created_at__month=i).count()
            
            months_noresponsed.append(no_responsed)
            
        data["responsed"] = months
        data["not_responsed"] = months_noresponsed
        data["total_not_responsed"] = total_not_responsed
        data["total_responsed"] = total_responsed
        
        
        return Response(data, status=200)
        
        
        
        
            
            
        
        
        