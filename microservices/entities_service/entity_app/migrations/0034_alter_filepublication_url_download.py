# Generated by Django 4.2 on 2025-01-14 03:56

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('entity_app', '0033_alter_anualreport_comment_aclaration_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='filepublication',
            name='url_download',
            field=models.FileField(blank=True, max_length=255, null=True, upload_to='publications/'),
        ),
    ]
