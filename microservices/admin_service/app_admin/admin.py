from django.contrib import admin

from app_admin.domain.models import FormFields, Establishment

# Register your models here.

admin.site.register(FormFields)
admin.site.register(Establishment)