cd code && \

celery -A auth_service worker -l info & \
gunicorn auth_service.wsgi:application --bind :8000 --workers 2