cd code && \

gunicorn auth_service.wsgi:application --bind :8000 --workers 2