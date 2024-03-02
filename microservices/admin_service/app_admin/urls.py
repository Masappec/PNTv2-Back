from django.urls import path,include
from app_admin.application.views.establishment import EstablishmentListAPI, EstablishmentDetail,\
    EstablishmentCreateAPI, EstablismentUpdate, EstablishmentDeactive, EstablishmentDetailUserSession
from app_admin.application.views.form_fields import FormField
from app_admin.application.views.public import EstablishmentPublicList, PedagogyAreaPublicView, EstablishmentPublicDetail
from app_admin.application.views.smtp import SMTPGET,SMTPUPDATE
from app_admin.application.views.frequently_asked_questions import FrequentlyAskedQuestionsView
from app_admin.application.views.pedagogy_area import PedagogyAreaCreateView, PedagogyAreaView
urlpatterns = [

    path('establishment/list', EstablishmentListAPI.as_view(), name='establishment-list'),
    path('establishment/detail/<pk>', EstablishmentDetail.as_view(), name='establishment-detail'),
    path('establishment/create', EstablishmentCreateAPI.as_view(), name='establishment-create'),
    path('establishment/update/<pk>', EstablismentUpdate.as_view(), name=''),
    path('establishment/delete/<pk>', EstablishmentDeactive.as_view(), name=''),
    path("establishment/user/session", EstablishmentDetailUserSession.as_view(), name=""),


    path('public/form-fields/', FormField.as_view(), name='form-fields'),
    path('public/establishment/list',EstablishmentPublicList.as_view(), name='establishment-public-list'),
    path('public/establishment/<slug>',EstablishmentPublicDetail.as_view(), name='establishment-public-detail'),
    path('public/pedagogy-area/', PedagogyAreaPublicView.as_view(), name='pedagogy-area-public-view'),
    
    
    path('smtp/', SMTPGET.as_view(), name='smtp'),
    path('smtp/update', SMTPUPDATE.as_view(), name='smtp-update'),
    
    path('pedagogy-area/create', PedagogyAreaCreateView.as_view(), name='pedagogy-area-create'),
    path('pedagogy-area/view', PedagogyAreaView.as_view(), name='pedagogy-area-list'),
    
]