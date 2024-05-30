#urls.py
from django.urls import path

from core.application.views.main import MainView, MainViewStream

urlpatterns = [
    path('public_api/', MainView.as_view()),
    path('public_api_stream/', MainViewStream.as_view()),
]