from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from entity_app.ports.repositories.message_repository import MessageRepository
from entity_app.domain.services.message_service import MessageService
from entity_app.adapters.serializers import MessageSerializer



class MessageView(APIView):
    permission_classes = [IsAuthenticated]

    service = MessageService(MessageRepository())
    def get(self, request):
        messages = self.service.get_unread_messages(request.user)
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)

    def post(self, request):
        data = request.data
        receiver = User.objects.get(id=data['receiver_id'])
        message = self.service.create_message(data['title'], data['content'], receiver)
        return Response({"message": "Message created successfully!"})
    