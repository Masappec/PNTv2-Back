from auth_service.celery import app


@app.task()
def ping_task():
    return "PING"
