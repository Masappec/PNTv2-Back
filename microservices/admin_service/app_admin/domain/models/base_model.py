from django.db import models


class BaseModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    deleted = models.BooleanField(default=False, null=True, blank=True)
    deleted_at = models.DateTimeField(null=True, blank=True, default=None)
    user_created = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, null=True, blank=True, related_name='%(class)s_user_created')
    user_updated = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, null=True, blank=True, related_name='%(class)s_user_updated')
    user_deleted = models.ForeignKey(
        'auth.User', on_delete=models.CASCADE, null=True, blank=True, related_name='%(class)s_user_deleted')
    ip = models.CharField(max_length=255, null=True, blank=True)

    class Meta:
        abstract = True

        verbose_name = 'BaseModel'
