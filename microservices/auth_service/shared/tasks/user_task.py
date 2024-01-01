from auth_service.celery import app


@app.task()
def send_user_created_event(user_id, establishment_id):
    
    return {
        'type': 'user_created',
        'payload': {
            'user_id': user_id,
            'establishment_id': establishment_id
        },
        
    }
