from django.contrib import admin

from app_admin.domain.models import FormFields, Establishment, UserEstablishment,\
    LawEnforcement, AccessToInformation, Email,Configuration, TutorialVideo, NormativeDocument, PedagogyArea

# Register your models here.

admin.site.register(FormFields)
admin.site.register(Establishment)
admin.site.register(UserEstablishment)
admin.site.register(LawEnforcement)
admin.site.register(AccessToInformation)
admin.site.register(Email)
admin.site.register(Configuration)
admin.site.register(TutorialVideo)
admin.site.register(NormativeDocument)
admin.site.register(PedagogyArea)