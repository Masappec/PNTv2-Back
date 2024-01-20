from django.urls import path,include
from entity_app.application.views.public import PublicationPublicView


urlpatterns = [

    path('public/publication/list', PublicationPublicView.as_view(), name='publication-list'),

]