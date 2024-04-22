from celery.signals import task_sent, task_success, task_failure


# Define manejadores de eventos
@task_sent.connect
def on_task_sent(sender, task_id, task, args, kwargs, **kwargs_extra):
    print(f"Task sent: {task_id} - {task}({args}, {kwargs})")


@task_success.connect
def on_task_success(sender, result, **kwargs):
    print(f"Task success: {result}")


@task_failure.connect
def on_task_failure(sender, task_id, exception, args, kwargs, traceback, einfo, **kwargs_extra):
    print(f"Task failed: {task_id} - {exception}")
    # Puedes manejar la lógica para gestionar los fallos aquí
