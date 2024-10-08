# Generated by Django 4.2 on 2024-03-26 21:52

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('app_admin', '0017_alter_pedagogyarea_options_establishment_slug'),
    ]

    operations = [
        migrations.AddField(
            model_name='establishment',
            name='address',
            field=models.CharField(default='', max_length=255),
            preserve_default=False,
        ),
        migrations.CreateModel(
            name='TypeOrganization',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('ip', models.CharField(blank=True, max_length=255, null=True)),
                ('name', models.CharField(max_length=255)),
                ('is_active', models.BooleanField(default=True)),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Tipo de Organización',
                'verbose_name_plural': 'Tipos de Organización',
            },
        ),
        migrations.CreateModel(
            name='TypeInstitution',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('ip', models.CharField(blank=True, max_length=255, null=True)),
                ('name', models.CharField(max_length=255)),
                ('is_active', models.BooleanField(default=True)),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Tipo de Institución',
                'verbose_name_plural': 'Tipos de Institución',
            },
        ),
        migrations.CreateModel(
            name='FunctionOrganization',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('ip', models.CharField(blank=True, max_length=255, null=True)),
                ('name', models.CharField(max_length=255)),
                ('is_active', models.BooleanField(default=True)),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Función de Organización',
                'verbose_name_plural': 'Funciones de Organización',
            },
        ),
        migrations.AddField(
            model_name='establishment',
            name='function_organization',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to='app_admin.functionorganization'),
        ),
        migrations.AddField(
            model_name='establishment',
            name='type_institution',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to='app_admin.typeinstitution'),
        ),
        migrations.AddField(
            model_name='establishment',
            name='type_organization',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to='app_admin.typeorganization'),
        ),
    ]
