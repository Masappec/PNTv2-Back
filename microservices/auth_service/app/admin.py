from django.contrib import admin

from app.domain.models import User, Person
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
# Register your models here.
admin.site.register(User)
admin.site.register(Permission)
admin.site.register(ContentType)
admin.site.register(Person)