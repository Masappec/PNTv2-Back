cd code && \
# Esperar a que Celery esté listo antes de iniciar Gunicorn
/code/wait-for-it.sh -t 30 celery -A admin_service worker -l info & \
gunicorn admin_service.wsgi:application --bind :8000 --workers 2
