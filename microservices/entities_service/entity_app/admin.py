from django.contrib import admin
from .domain.models.publication import Publication, FilePublication, TypePublication, Tag
from entity_app.domain.models.solicity import Solicity, Category, TimeLineSolicity, Insistency, Extension, SolicityResponse
from entity_app.domain.models.transparency_active import EstablishmentNumeral, Numeral, TemplateFile, ColumnFile, TransparencyActive
from entity_app.domain.models.transparecy_foc import TransparencyFocal
from django.contrib.auth.models import Permission, ContentType
# Register your models here.
admin.site.register(ContentType)

admin.site.register(Publication)
admin.site.register(FilePublication)
admin.site.register(TypePublication)
admin.site.register(Tag)
admin.site.register(Solicity)
admin.site.register(EstablishmentNumeral)
admin.site.register(Numeral)
admin.site.register(TemplateFile)
admin.site.register(TransparencyActive)
admin.site.register(Category)
admin.site.register(TimeLineSolicity)
admin.site.register(Insistency)
admin.site.register(Extension)
admin.site.register(SolicityResponse)
admin.site.register(TransparencyFocal)
admin.site.register(Permission)


@admin.register(ColumnFile)
class ColumnFileAdmin(admin.ModelAdmin):
    list_display = ('name', )
    list_filter = ('name', )
    search_fields = ('name', )