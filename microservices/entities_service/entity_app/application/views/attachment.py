
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from entity_app.adapters.serializers import AttachmentSerializer
from entity_app.adapters.impl.attachment_impl import AttachmentImpl
from entity_app.domain.services.attachment_service import AttachmentService



class AttachmentCreateView(APIView):
    """
    Create a new attachment.
    """
    permission_classes = (IsAuthenticated,)
    
    
    
    def __init__(self, *args, **kwargs):
        self.service = AttachmentService(AttachmentImpl())

    def post(self, request, *args, **kwargs):
        try:
            serializer = AttachmentSerializer(data=request.data)
            if serializer.is_valid():
                data = self.service.save(serializer.validated_data)
                serializer_res = AttachmentSerializer(data)
                return Response(serializer_res.data, status=status.HTTP_201_CREATED)
            
            else:
                data = {
                    'message': ",".join(serializer.errors),
                    'status': status.HTTP_400_BAD_REQUEST,
                    'json': {}
                }
                return Response(data, status=status.HTTP_400_BAD_REQUEST)
            
        except Exception as e:
            data = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }
            return Response(data, status=status.HTTP_400_BAD_REQUEST)