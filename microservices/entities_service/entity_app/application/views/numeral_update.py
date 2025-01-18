##
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from typing import Any
from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
import logging

class DeleteNumeralView(APIView):
    def __init__(self, **kwargs: Any) -> None:
        self.service = NumeralService(
            numeral_repository=NumeralImpl()
        )

    def delete(self, request, numeral_id, establishment_id):
        """
        Endpoint para eliminar un numeral.
        """
        logging.info(f"Eliminando numeral con ID {numeral_id} del establecimiento con ID {establishment_id}.")
        try:
            self.service.delete_numeral(numeral_id, establishment_id)
            return Response({
                "message": "Numeral eliminado exitosamente."
            }, status=status.HTTP_200_OK)
        except ValueError as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"error": "Error interno del servidor."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
