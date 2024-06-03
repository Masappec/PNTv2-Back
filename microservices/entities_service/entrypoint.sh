#!/bin/bash

cd code
export PYTHONPATH=/code:$PYTHONPATH

# Iniciar Gunicorn en segundo plano y esperar a que se inicie
gunicorn entities_service.wsgi:application --bind :8000 --workers 4 &
GUNICORN_PID=$!
sleep 10  # Añadir un retardo para esperar a que Gunicorn se inicie completamente

# Iniciar Celery Worker en segundo plano y esperar a que se inicie
celery -A entities_service worker -l info &
CELERY_WORKER_PID=$!
sleep 10  # Añadir un retardo para esperar a que Celery Worker se inicie completamente

# Iniciar Celery Beat
celery -A entities_service beat -l info
CELERY_BEAT_PID=$!

# Función para manejar la terminación de procesos al recibir una señal de interrupción (SIGINT/SIGTERM)
cleanup() {
    echo "Deteniendo Gunicorn..."
    kill $GUNICORN_PID
    wait $GUNICORN_PID

    echo "Deteniendo Celery Worker..."
    kill $CELERY_WORKER_PID
    wait $CELERY_WORKER_PID

    echo "Deteniendo Celery Beat..."
    kill $CELERY_BEAT_PID
    wait $CELERY_BEAT_PID

    echo "Todos los procesos han sido detenidos."
}

# Atrapar señales de interrupción y ejecutar la función cleanup
trap cleanup SIGINT SIGTERM

# Esperar a que los procesos terminen (mantener el contenedor en ejecución)
wait $GUNICORN_PID
wait $CELERY_WORKER_PID
wait $CELERY_BEAT_PID
