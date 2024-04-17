from django.contrib import admin
from .domain.models.publication import Publication, FilePublication, TypePublication, Tag
from entity_app.domain.models.solicity import Solicity, Category
from entity_app.domain.models.transparency_active import EstablishmentNumeral, Numeral, TemplateFile, ColumnFile, TransparencyActive

# Register your models here.
admin.site.register(Publication)
admin.site.register(FilePublication)
admin.site.register(TypePublication)
admin.site.register(Tag)
admin.site.register(Solicity)
admin.site.register(EstablishmentNumeral)
admin.site.register(Numeral)
admin.site.register(TemplateFile)
admin.site.register(ColumnFile)
admin.site.register(TransparencyActive)
admin.site.register(Category)
