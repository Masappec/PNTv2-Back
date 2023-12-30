from django.urls import path,include
from app_admin.domain.views.establishment import EstablishmentListAPI


urlpatterns = [

    path('establishment/list', EstablishmentListAPI.as_view(), name='establishment-list'),
]