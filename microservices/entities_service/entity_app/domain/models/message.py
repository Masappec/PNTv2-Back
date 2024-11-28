from django.db import models
from django.contrib.auth.models import User



class Message(models.Model):
    title = models.CharField(max_length=255)
    content = models.TextField()
    is_read = models.BooleanField(default=False)
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='messages')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title
