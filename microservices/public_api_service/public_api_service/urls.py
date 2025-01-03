"""
URL configuration for public_api_service project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from asyncio import protocols
from django.contrib import admin
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from django.urls import path,include
from drf_yasg.generators import OpenAPISchemaGenerator


class CustomSchemaGenerator(OpenAPISchemaGenerator):
    def get_schema(self, request=None, public=False):
        schema = super().get_schema(request, public)
        schema.host = "transparencia.dpe.gob.ec/backend/v1/public"
        schema.schemes = ["https", "http"]
        return schema
    
schema_view = get_schema_view(
    openapi.Info(
        title="API Publica de Portal de Transparencia",
        default_version='v1',
        description="Test description",
        terms_of_service="https://www.google.com/policies/terms/",
        contact=openapi.Contact(email="contact@snippets.local"),
        license=openapi.License(name="BSD License"),
    ),
    public=True,
    generator_class=CustomSchemaGenerator,

)

urlpatterns = [
    path('',include('core.urls')),
    path('swagger<format>/', schema_view.without_ui(cache_timeout=0),
         name='schema-json'),
    path('swagger/', schema_view.with_ui('swagger',
         cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc',
         cache_timeout=0), name='schema-redoc'),
]