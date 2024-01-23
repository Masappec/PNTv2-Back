from django.urls import path,include
from entity_app.application.views.public import PublicationPublicView,PublicationDetail 
from entity_app.application.views.publication import PublicationCreateAPI, PublicationUpdateAPI, PublicationsView

from entity_app.application.views.file_publication import FilePublicationCreateView, FilePublicationListEstablishemtSession, FilePublicationDelete
from entity_app.application.views.tag import TagView, TagCreateView
urlpatterns = [

    path('public/transparency/active/list', PublicationPublicView.as_view(), name='publication-list'),
    path('public/transparency/active/detail/<slug>', PublicationDetail.as_view(), name='publication-detail'),
 
    path('publications/list', PublicationsView.as_view(), name='publications-all'),
    
    path('publications/file/create', FilePublicationCreateView.as_view(), name='file-publication-create'),
    path('publications/file/list', FilePublicationListEstablishemtSession.as_view(), name='file-publication-list'),
    path('publications/file/delete/<pk>', FilePublicationDelete.as_view(), name='file-publication-delete'),
    
    path('tags/list', TagView.as_view(), name='tag-list'),
    path('tags/create', TagCreateView.as_view(), name='tag-create'),
    
    path('publications/create', PublicationCreateAPI.as_view(), name='publication-create'),
    path('publications/edit', PublicationUpdateAPI.as_view(), name='publication-edit'),
]