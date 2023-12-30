cd code && \
python3 manage.py migrate && \
python3 manage.py loaddata fixtures/admin.json && \
gunicorn admin_service.wsgi:application --bind :8000 --workers 2