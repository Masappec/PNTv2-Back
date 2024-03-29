
from entities_service.celery import app


@app.task(name='user.user_created')
def send_user_created_event(user_id, establishment_id):
    app.send_task('admin_service.admin.user_created', args=[
        user_id, establishment_id], queue='admin_queue')
    return {
        'type': 'user_created',
        'payload': {
            'user_id': user_id,
            'establishment_id': establishment_id
        },

    }
