
from typing import Any
from django.contrib.auth.models import AbstractUser
from django.contrib.auth.models import Permission
from django.contrib.auth.models import Group
from django.db import connection, models


class BaseModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    ip = models.CharField(max_length=255, null=True, blank=True)

    class Meta:
        abstract = True


class Role(Group):

    class Meta:
        proxy = True

        # add fields


class User(AbstractUser, BaseModel):

    class Meta:
        db_table = 'auth_user'
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'
        ordering = ['-created_at']

    @staticmethod
    def register_citizen_user(username, email, password, first_name, last_name, identification, phone,
                              city, race, disability, age_range, province, gender, accept_terms):

        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT auth_register_citizen_user(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", [
                    username,
                    email,
                    password,
                    first_name,
                    last_name,
                    identification,
                    phone,
                    city,
                    race,
                    disability,
                    age_range,
                    province,
                    gender,
                    accept_terms,

                ])

                row = cursor.fetchone()

                return row[0]
        except Exception as e:
            print(e)
            return None
        finally:
            cursor.close()


class Person(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, null=True, blank=True, related_name='person')
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    identification = models.CharField(max_length=255)
    phone = models.CharField(max_length=255, null=True, blank=True)
    address = models.CharField(max_length=255, null=True, blank=True)
    city = models.CharField(max_length=255, null=True, blank=True)
    country = models.CharField(
        max_length=255, null=True, blank=True, default='Ecuador')
    province = models.CharField(max_length=255, null=True, blank=True)
    group_priority = models.CharField(max_length=255, null=True, blank=True)
    job = models.CharField(max_length=255, null=True, blank=True)
    gender = models.CharField(max_length=255, null=True, blank=True, choices=(
        ('masculino', 'Masculino'),
        ('femenino', 'Femenino'),
        ('otro', 'Otro')
    ))
    age_range = models.CharField(max_length=255, null=True, blank=True)
    race = models.CharField(max_length=255, null=True, blank=True)
    disability = models.BooleanField(default=False)

    accept_terms = models.BooleanField(default=False)

    objects = models.Manager()

    class Meta:
        db_table = 'auth_person'
        verbose_name = 'Datos Personales'
        verbose_name_plural = 'Datos Personales'
        ordering = ['-id']
