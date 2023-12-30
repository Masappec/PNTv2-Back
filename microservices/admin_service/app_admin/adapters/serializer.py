from rest_framework.serializers import Serializer, ModelSerializer
from app_admin.domain.models import Establishment

class EstablishmentListSerializer(ModelSerializer):
    
    
    class Meta:
        model = Establishment
        fields = '__all__'