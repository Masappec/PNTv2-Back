from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from typing import Any
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl

class UpdateNumeralStateView(APIView):
    def __init__(self, **kwargs: Any) -> None:
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

    def patch(self, request, numeral_id):
        """
        Endpoint para actualizar el estado de un numeral (is_selected=True).
        """
        try:
            # Llamar al servicio para actualizar el estado
            updated_numeral = self.service.update_numeral_state(numeral_id, is_default=True)
            # Suponiendo que 'updated_numeral' contiene la información completa del numeral
            return Response({
                "message": "Numeral actualizado exitosamente.",
            }, status=status.HTTP_200_OK)
        except ValueError as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"error": "Error interno del servidor."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
