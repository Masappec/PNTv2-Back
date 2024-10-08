# Generated by Django 4.2 on 2024-01-06 21:10

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('app_admin', '0013_establishment_is_active_alter_establishment_code'),
    ]

    operations = [
        migrations.AddField(
            model_name='accesstoinformation',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='accesstoinformation',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='accesstoinformation',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='establishment',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='establishment',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='establishment',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='formfields',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='formfields',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='formfields',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='frequentlyaskedquestions',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='frequentlyaskedquestions',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='frequentlyaskedquestions',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='lawenforcement',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='lawenforcement',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='lawenforcement',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='normativedocument',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='normativedocument',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='normativedocument',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='pedagogyarea',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='pedagogyarea',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='pedagogyarea',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='tutorialvideo',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='tutorialvideo',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='tutorialvideo',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='userestablishment',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='userestablishment',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='userestablishment',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
        migrations.CreateModel(
            name='Email',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('from_email', models.CharField(max_length=255)),
                ('to_email', models.CharField(max_length=255)),
                ('subject', models.CharField(max_length=255)),
                ('body', models.TextField()),
                ('status', models.CharField(blank=True, choices=[('pending', 'Pendiente'), ('sent', 'Enviado'), ('error', 'Error')], max_length=255, null=True)),
                ('error', models.TextField(blank=True, null=True)),
                ('bcc', models.CharField(blank=True, max_length=255, null=True)),
                ('cc', models.CharField(blank=True, max_length=255, null=True)),
                ('reply_to', models.CharField(blank=True, max_length=255, null=True)),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Email',
                'verbose_name_plural': 'Emails',
            },
        ),
        migrations.CreateModel(
            name='Configuration',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('name', models.CharField(max_length=255)),
                ('value', models.CharField(max_length=255)),
                ('is_active', models.BooleanField(default=True)),
                ('type_config', models.CharField(blank=True, max_length=255, null=True)),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Configuración',
                'verbose_name_plural': 'Configuraciones',
                'permissions': (('can_view_configuration', 'Can view configuration'),),
            },
        ),
    ]
