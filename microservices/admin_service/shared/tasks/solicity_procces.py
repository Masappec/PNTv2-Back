from admin_service.celery import app


@app.task()
def change_status_solicity():
    pass
