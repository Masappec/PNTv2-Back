#urls.py
from django.urls import path

from core.application.views.main import MainView
from core.application.views.personal_view import PersonalRemuneraciones
from core.application.views.audiencias_view import AudienciasView
from core.application.views.presupuestos import PresupuestoView
from core.application.views.solicities_view import SolicitiesView
urlpatterns = [
    path('public_api/', MainView.as_view()),
    path('public/personal-remuneraciones/', PersonalRemuneraciones.as_view()),
    path('public/audiencias', AudienciasView.as_view()),
    path('public/presupuesto', PresupuestoView.as_view()),
    path('public/solicitudes-y-servicios/', SolicitiesView.as_view())
]