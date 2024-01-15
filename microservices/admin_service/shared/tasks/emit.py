
from admin_service.celery import app
 

@app.task()
def ping_task():
    return "PONG"