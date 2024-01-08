from django.urls import path,include
from app_admin.application.views.establishment import EstablishmentListAPI, EstablishmentDetail,\
    EstablishmentCreateAPI, EstablismentUpdate, EstablishmentDeactive
from app_admin.application.views.form_fields import FormField
from app_admin.application.views.smtp import SMTPGET,SMTPUPDATE

urlpatterns = [

    path('establishment/list', EstablishmentListAPI.as_view(), name='establishment-list'),
    path('establishment/detail/<pk>', EstablishmentDetail.as_view(), name='establishment-detail'),
    path('establishment/create', EstablishmentCreateAPI.as_view(), name='establishment-create'),
    path('establishment/update/<pk>', EstablismentUpdate.as_view(), name=''),
    path('establishment/delete/<pk>', EstablishmentDeactive.as_view(), name=''),
    

    path('public/form-fields/', FormField.as_view(), name='form-fields'),
    
    
    path('smtp/', SMTPGET.as_view(), name='smtp'),
    path('smtp/update', SMTPUPDATE.as_view(), name='smtp-update'),
]