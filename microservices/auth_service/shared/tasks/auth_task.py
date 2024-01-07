from auth_service.celery import app


@app.task()
def auth_send_password_reset_event(current_user,username,email,reset_password_url):
    return {
        'type': 'auth_password_reset',
        'payload': {
            'current_user': current_user,
            'username': username,
            'email': email,
            'reset_password_url': reset_password_url
        },
        
    }