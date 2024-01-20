

from .base_model import BaseModel
from django.db import models


class ActivityLog(BaseModel):
    """
    modelo para guardar los logs de actividad de los usuarios
    """

    user = models.ForeignKey(
        "auth.User", on_delete=models.CASCADE, related_name="activity_logs"
    )
    activity = models.CharField(max_length=255)
    description = models.TextField()
    ip_address = models.CharField(max_length=255)
    user_agent = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return str(self.description)

    class Meta:
        db_table = "activity_log"
        verbose_name = "Activity Log"
        verbose_name_plural = "Activity Logs"