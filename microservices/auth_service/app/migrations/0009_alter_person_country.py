# Generated by Django 4.2 on 2023-12-31 14:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0008_alter_person_options_alter_person_address_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='person',
            name='country',
            field=models.CharField(blank=True, default='Ecuador', max_length=255, null=True),
        ),
    ]
