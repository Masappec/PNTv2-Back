# Generated by Django 4.2 on 2023-12-30 00:25

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app_admin', '0007_pedagogyarea_tutorialvideo_normativedocument_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='establishment',
            name='code',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
