cd code && \

gunicorn admin_service.wsgi:application --bind :8001 --workers 2