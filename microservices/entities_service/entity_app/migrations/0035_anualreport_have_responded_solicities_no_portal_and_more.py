# Generated by Django 4.2 on 2025-01-16 02:31

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('entity_app', '0034_alter_filepublication_url_download'),
    ]

    operations = [
        migrations.AddField(
            model_name='anualreport',
            name='have_responded_solicities_no_portal',
            field=models.BooleanField(default=False),
        ),
        migrations.CreateModel(
            name='GenerateAnualReport',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('ip', models.CharField(blank=True, max_length=255, null=True)),
                ('year', models.IntegerField()),
                ('file', models.FileField(blank=True, max_length=255, null=True, upload_to='generate_anual_report/<django.db.models.fields.IntegerField>/')),
                ('is_global', models.BooleanField(default=False)),
                ('establishment', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='generate_anual_report_establishment', to='entity_app.establishmentextended')),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'BaseModel',
                'abstract': False,
            },
        ),
    ]