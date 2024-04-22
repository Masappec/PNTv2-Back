cd code && \
export PYTHONPATH=/code:$PYTHONPATH
# Esperar a que Celery esté listo antes de iniciar Gunicorn
gunicorn public_api_service.wsgi:application --bind :8000 --workers 4 & \
sleep 10 && \  # Añadir un retardo opcional si es necesario esperar a que Gunicorn se inicie completamente
celery -A public_api_service worker -l info && \
sleep 10 && \ 
celery -A public_api_service beat -l info 

