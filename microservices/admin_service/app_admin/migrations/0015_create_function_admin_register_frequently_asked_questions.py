
from django.db import migrations, models
import os


def create_procedure_admin_register_frequently(apps, schema_editor):
    sp_path = os.path.join(os.path.dirname(__file__), 'functions', 'admin_register_frequentlyaskedquestions.sql')
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
        ('app_admin', '0014_accesstoinformation_user_created_and_more'),
    ]

    operations = [
        migrations.RunPython(create_procedure_admin_register_frequently),

    ]
