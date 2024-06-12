from rest_framework.views import APIView
from rest_framework.response import Response
from datetime import datetime
from core.models import TransparencyActive
from rest_framework import serializers

class PresupuestoView(APIView):
    
    
    class OutputSerializer(serializers.ModelSerializer):
        class Meta:
            model = TransparencyActive
            fields = '__all__'
            
            
    def get(self, request, *args, **kwargs):
        """
        Get a list of users.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:
            year = request.query_params.get('year', None)
            month = request.query_params.get('month', None)
            establishment_id = request.query_params.get(
                'establishment_id', None)

            if establishment_id is None:
                raise ValueError('Debe seleccionar un establecimiento')

            if year is None:
                year = datetime.now().year

            if month is None:
                month = datetime.now().month

            queryset = None

            queryset = TransparencyActive.objects.filter(
                year=year,
                month=month,
                establishment_id=establishment_id,
                numeral__name= 'Numeral 16'
            )

            serializer = self.OutputSerializer(queryset, many=True)
            return Response(serializer.data)

        except Exception as e:
            return Response({
                'message': str(e),
                'status': 400,
                'json': {}
            }, status=400)