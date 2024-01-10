
from django.db import migrations, models
import os


def create_procedure_admin_register_tutorialvideo(apps, schema_editor):
    sp_path = os.path.join(os.path.dirname(__file__), 'functions', 'admin_register_tutorialvideo.sql')
    sql = None
    with open(sp_path, 'r') as f:
        sql = f.read()

    # Ejecutar el SQL
    if sql is not None:
        with schema_editor.connection.cursor() as cursor:
            cursor.execute(sql)

    else:
        raise Exception('No se pudo leer el archivo SQL')


class Migration(migrations.Migration):
    dependencies = [
        ('app_admin', '0015_create_function_admin_register_frequently_asked_questions'),
    ]

    operations = [
        migrations.RunPython(create_procedure_admin_register_tutorialvideo),

    ]
