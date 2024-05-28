from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import serializers
from core.models import Metadata, CSVData
class MainView(APIView):
    
    
    
    
    class InputSerializer(serializers.Serializer):
        numerals = serializers.ListField(child=serializers.StringField())
        articles = serializers.StringField()
        
        search = serializers.CharField()
        
        fields = serializers.ListField(child=serializers.StringField())
        
        
    def post(self, request):
        serializer = self.InputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        numerals = serializer.validated_data['numerals']
        articles = serializer.validated_data['articles']
        search = serializer.validated_data['search']
        fields = serializer.validated_data['fields']
        
        #search
        metadata = Metadata.objects.filter(
            numeral__in=numerals,
            article=articles,
        )
        
        res = CSVData.objects.filter(
            metadata__in=metadata,
            data__contains=search,
        )

        
        
        
        return Response({
            'data': res
        })
        
        