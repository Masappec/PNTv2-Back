from entity_app.ports.repositories.message_repository import MessageRepository

class MessageService:
    def __init__(self, repository):
        self.repository = repository

    def get_unread_messages(self, user):
        return self.repository.get_messages_for_user(user)

    def create_message(self, title, content, receiver):
        message = MessageRepository(title=title, content=content, receiver=receiver)
        message.save()
        return message