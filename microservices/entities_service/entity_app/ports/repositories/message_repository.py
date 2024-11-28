from abc import ABC
from entity_app.domain.models.message import Message

class MessageRepository(ABC):
    def get_messages_for_user(self, user):
        return user.messages.filter(is_read=False).order_by('-created_at')



    def mark_message_as_read(self, message_id):
        message = Message.objects.filter(id=message_id).first()
        if message:
            message.is_read = True
            message.save()
        return message