from django.contrib import admin
from .domain.models.publication import Publication, FilePublication, TypePublication, Tag
from entity_app.domain.models.solicity import Solicity

# Register your models here.
admin.site.register(Publication)
admin.site.register(FilePublication)
admin.site.register(TypePublication)
admin.site.register(Tag)
admin.site.register(Solicity)