
from rest_framework.views import APIView
from rest_framework.response import Response
from entity_app.adapters.impl.transparency_active_impl import TransparencyActiveImpl
from entity_app.domain.services.transparency_active_service import TransparencyActiveService
from datetime import datetime
from entity_app.adapters.serializers import TransparencyActiveListSerializer


class TransparencyActivePublicListView(APIView):

    permission_classes = []
    serializer_class = TransparencyActiveListSerializer

    def __init__(self):
        self.service = TransparencyActiveService(TransparencyActiveImpl())

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
            order_by = request.query_params.get('sort[]', None)
            if establishment_id is None:
                raise ValueError('Debe seleccionar un establecimiento')

            if year is None:
                year = datetime.now().year

            if month is None:
                month = datetime.now().month

            queryset = None
            if establishment_id=="0":
                queryset = self.service.get_all_year_month(year, month)
            else:
                queryset = self.service.get_by_year_month(
                    year, month, establishment_id)
            if order_by is not None:
                queryset = queryset.order_by(order_by)
            serializer = self.serializer_class(queryset, many=True)
            return Response(serializer.data)

        except Exception as e:
            return Response({
                'message': str(e),
                'status': 400,
                'json': {}
            }, status=400)



