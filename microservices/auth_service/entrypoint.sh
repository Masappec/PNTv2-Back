cd code && \
python3 manage.py migrate && \
gunicorn auth_service.wsgi:application --bind :8000 --workers 2