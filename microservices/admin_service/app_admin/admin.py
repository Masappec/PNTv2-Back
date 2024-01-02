from django.contrib import admin

from app_admin.domain.models import FormFields, Establishment, UserEstablishment, LawEnforcement, AccessToInformation

# Register your models here.

admin.site.register(FormFields)
admin.site.register(Establishment)
admin.site.register(UserEstablishment)
admin.site.register(LawEnforcement)
admin.site.register(AccessToInformation)