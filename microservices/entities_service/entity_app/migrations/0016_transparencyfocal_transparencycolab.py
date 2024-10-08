# Generated by Django 4.2 on 2024-03-29 15:55

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('entity_app', '0015_numeral_is_default'),
    ]

    operations = [
        migrations.CreateModel(
            name='TransparencyFocal',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('ip', models.CharField(blank=True, max_length=255, null=True)),
                ('slug', models.SlugField(blank=True, editable=False, max_length=255, null=True, unique=True)),
                ('month', models.IntegerField()),
                ('year', models.IntegerField()),
                ('status', models.CharField(choices=[('pending', 'Pendiente'), ('ingress', 'Ingresado')], default='pending', max_length=255)),
                ('published', models.BooleanField(default=False)),
                ('published_at', models.DateTimeField(blank=True, null=True)),
                ('max_date_to_publish', models.DateTimeField(blank=True, null=True)),
                ('establishment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='transparency_focal', to='entity_app.establishmentextended')),
                ('files', models.ManyToManyField(blank=True, related_name='transparency_focal', to='entity_app.filepublication')),
                ('numeral', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='transparency_focal', to='entity_app.numeral')),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Transparencia Focalizada',
                'verbose_name_plural': 'Transparencias Focalizada',
                'unique_together': {('establishment', 'numeral', 'month', 'year')},
            },
        ),
        migrations.CreateModel(
            name='TransparencyColab',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('ip', models.CharField(blank=True, max_length=255, null=True)),
                ('slug', models.SlugField(blank=True, editable=False, max_length=255, null=True, unique=True)),
                ('month', models.IntegerField()),
                ('year', models.IntegerField()),
                ('status', models.CharField(choices=[('pending', 'Pendiente'), ('ingress', 'Ingresado')], default='pending', max_length=255)),
                ('published', models.BooleanField(default=False)),
                ('published_at', models.DateTimeField(blank=True, null=True)),
                ('max_date_to_publish', models.DateTimeField(blank=True, null=True)),
                ('establishment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='transparency_colab', to='entity_app.establishmentextended')),
                ('files', models.ManyToManyField(blank=True, related_name='transparency_colab', to='entity_app.filepublication')),
                ('numeral', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='transparency_colab', to='entity_app.numeral')),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Transparencia Colaborativa',
                'verbose_name_plural': 'Transparencias Colaborativa',
                'unique_together': {('establishment', 'numeral', 'month', 'year')},
            },
        ),
    ]
