cd code && \
export PYTHONPATH=/code:$PYTHONPATH

# Esperar a que Celery esté listo antes de iniciar Gunicorn
# Iniciar Gunicorn primero
gunicorn auth_service.wsgi:application --bind :8000 --workers 4 & \
sleep 10 && \  # Añadir un retardo opcional si es necesario esperar a que Gunicorn se inicie completamente
celery -A auth_service worker -l info
