
from public_api_service.celery import app


@app.task()
def ping_task():
    return "PONG"
