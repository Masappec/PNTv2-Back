from django.urls import path,include
from entity_app.application.views.public import PublicationPublicView,PublicationDetail


urlpatterns = [

    path('public/transparency/active/list', PublicationPublicView.as_view(), name='publication-list'),
    path('public/transparency/active/detail/<int:pk>', PublicationDetail.as_view(), name='publication-detail'),

]