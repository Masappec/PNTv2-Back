# Generated by Django 4.2 on 2024-04-06 20:25

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('entity_app', '0017_rename_identification_solicity_city_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='solicity',
            name='date',
            field=models.DateTimeField(default=datetime.datetime.now),
        ),
    ]
