cd code && \
celery -A admin_service worker -l info & \
gunicorn admin_service.wsgi:application --bind :8001 --workers 2