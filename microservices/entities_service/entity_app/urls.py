from django.urls import path,include
from entity_app.application.views.public import PublicationPublicView,PublicationDetail 
from entity_app.application.views.publication import PublicationCreateAPI, PublicationUpdateAPI, PublicationsView


urlpatterns = [

    path('public/transparency/active/list', PublicationPublicView.as_view(), name='publication-list'),
    path('public/transparency/active/detail/<slug>', PublicationDetail.as_view(), name='publication-detail'),
 
    path('publications/list', PublicationsView.as_view(), name='publications-all'),
    path('publications/create', PublicationCreateAPI.as_view(), name='publication-create'),
    path('publications/edit', PublicationUpdateAPI.as_view(), name='publication-edit'),
]