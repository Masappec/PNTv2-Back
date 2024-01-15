from auth_service.celery import app


@app.task()
def auth_send_password_reset_event(current_user_id,username,email,reset_password_url):
    return {
        'type': 'auth_password_reset',
        'payload': {
            'current_user': current_user_id,
            'username': username,
            'email': email,
            'reset_password_url': reset_password_url
        },
        
    }
    
@app.task()
def auth_send_activate_account_event(email, uidb64, token,username):
     

    return {
            'type': 'auth_activate_account',
            'payload': {
                'uidb64': uidb64,
                'username': username,
                'email': email,
                'token': token
            },

        }