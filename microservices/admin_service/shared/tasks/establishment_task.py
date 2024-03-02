
from admin_service.celery import app


@app.task()
def establishment_created_event(numerals_id,establishment_id):
    
    return {
        'type': 'establishment_created',
        'payload': {
            'numerals_id': numerals_id,
            'establishment_id': establishment_id
        },
    }