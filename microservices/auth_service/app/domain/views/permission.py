from typing import Any
from app.domain.services.permission_service import PermissionService
from app.adapters.impl.permission_impl import PermissionRepositoryImpl
from app.adapters.serializer import PermissionSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response


class PermissionListAPI(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PermissionSerializer

    def __init__(self, **kwargs: Any):
        super().__init__(**kwargs)
        self.permission_service = PermissionService(PermissionRepositoryImpl())

    def get(self, request, *args, **kwargs):
        data = self.permission_service.get_permissions()
        res = self.serializer_class(data, many=True)
        return Response(data=res.data, status=200)
