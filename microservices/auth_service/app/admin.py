from django.contrib import admin

from app.domain.models import User
from django.contrib.auth.models import Permission
# Register your models here.
admin.site.register(User)

admin.site.register(Permission)