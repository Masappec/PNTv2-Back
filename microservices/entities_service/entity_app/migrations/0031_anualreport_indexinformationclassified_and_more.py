
from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('entity_app', '0030_alter_columnfile_code_alter_columnfile_name_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='AnualReport',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('ip', models.CharField(blank=True, max_length=255, null=True)),
                ('year', models.IntegerField()),
                ('month', models.IntegerField()),
                ('have_public_records', models.BooleanField()),
                ('norme_archive_utility', models.CharField(max_length=255)),
                ('comment_aclaration', models.TextField()),
                ('total_saip', models.IntegerField()),
                ('did_you_entity_receive', models.BooleanField()),
                ('total_saip_in_portal', models.IntegerField()),
                ('total_saip_no_portal', models.IntegerField()),
                ('description_rason_no_portal', models.TextField()),
                ('total_no_registered', models.IntegerField()),
                ('comment_aclaration_no_registered', models.TextField()),
                ('reserve_information', models.BooleanField()),
                ('number_of_reserves', models.IntegerField()),
                ('number_of_confidential', models.IntegerField()),
                ('number_of_secret', models.IntegerField()),
                ('number_of_secretism', models.IntegerField()),
                ('have_quality_problems', models.BooleanField()),
                ('total_quality_problems', models.IntegerField()),
                ('description_quality_problems', models.TextField()),
                ('have_sanctions', models.BooleanField()),
                ('total_organic_law_public_service', models.IntegerField()),
                ('description_organic_law_public_service', models.TextField()),
                ('total_organic_law_contraloria', models.IntegerField()),
                ('description_organic_law_contraloria', models.TextField()),
                ('total_organic_law_national_system', models.IntegerField()),
                ('description_organic_law_national_system', models.TextField()),
                ('total_organic_law_citizen_participation', models.IntegerField()),
                ('description_organic_law_citizen_participation', models.TextField()),
                ('implemented_programs', models.BooleanField()),
                ('total_programs', models.IntegerField()),
                ('description_programs', models.TextField()),
                ('have_activities', models.BooleanField()),
                ('total_activities', models.IntegerField()),
                ('description_activities', models.TextField()),
                ('establishment_id', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='anual_report_establishment', to='entity_app.establishmentextended')),
            ],
            options={
                'verbose_name': 'BaseModel',
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='IndexInformationClassified',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('updated_at', models.DateTimeField(auto_now=True, null=True)),
                ('deleted', models.BooleanField(blank=True, default=False, null=True)),
                ('deleted_at', models.DateTimeField(blank=True, default=None, null=True)),
                ('ip', models.CharField(blank=True, max_length=255, null=True)),
                ('topic', models.CharField(max_length=255)),
                ('legal_basis', models.CharField(max_length=255)),
                ('classification_date', models.DateField()),
                ('period_of_validity', models.CharField(max_length=255)),
                ('amplation_effectuation', models.BooleanField()),
                ('ampliation_description', models.TextField()),
                ('ampliation_date', models.DateField()),
                ('ampliation_period_of_validity', models.CharField(max_length=255)),
                ('anual_report', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='entity_app.anualreport')),
                ('user_created', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL)),
                ('user_deleted', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL)),
                ('user_updated', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'BaseModel',
                'abstract': False,
            },
        ),
        migrations.AddField(
            model_name='anualreport',
            name='information_classified',
            field=models.ManyToManyField(blank=True, related_name='anual_report_information_classified', to='entity_app.indexinformationclassified'),
        ),
        migrations.AddField(
            model_name='anualreport',
            name='user_created',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_created', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='anualreport',
            name='user_deleted',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_deleted', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='anualreport',
            name='user_updated',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='%(class)s_user_updated', to=settings.AUTH_USER_MODEL),
        ),
    ]
