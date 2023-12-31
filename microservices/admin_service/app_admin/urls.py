from django.urls import path,include
from app_admin.domain.views.establishment import EstablishmentListAPI, EstablishmentCreateAPI, EstablismentUpdate, EstablishmentDeactive
from app_admin.domain.views.form_fields import FormField

urlpatterns = [

    path('establishment/list', EstablishmentListAPI.as_view(), name='establishment-list'),
    path('establishment/create', EstablishmentCreateAPI.as_view(), name='establishment-create'),
    path('establishment/update/<pk>', EstablismentUpdate.as_view(), name=''),
    path('establishment/delete/<pk>', EstablishmentDeactive.as_view(), name=''),

    path('public/form-fields/', FormField.as_view(), name='form-fields'),
]