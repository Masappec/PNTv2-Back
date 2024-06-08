#urls.py
from django.urls import path

from core.application.views.main import MainView, MainViewStream
from core.application.views.personal_view import PersonalRemuneraciones
from core.application.views.audiencias_view import AudienciasView
urlpatterns = [
    path('public_api/', MainView.as_view()),
    path('public_api_stream/', MainViewStream.as_view()),
    path('public/personal-remuneraciones/', PersonalRemuneraciones.as_view()),
    path('public/audiencias', AudienciasView.as_view())
]