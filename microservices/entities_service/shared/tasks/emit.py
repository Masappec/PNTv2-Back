
from entities_service.celery import app


@app.task()
def ping_task():
    print("PONG")
    return "PONG"
