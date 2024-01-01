
from typing import Any
from django.contrib.auth.models import AbstractUser
from django.contrib.auth.models import Permission
from django.contrib.auth.models import Group
from django.db import models



class BaseModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        abstract = True



class Role(Group):
    
    class Meta:
        proxy = True
        
        #add fields
        
        

class User(AbstractUser, BaseModel):

    class Meta:
        db_table = 'auth_user'
        verbose_name = 'user'
        verbose_name_plural = 'users'
        ordering = ['-created_at']
    

class Person(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True, related_name='person')
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    identification = models.CharField(max_length=255)
    phone = models.CharField(max_length=255, null=True, blank=True)
    address = models.CharField(max_length=255, null=True, blank=True)
    city = models.CharField(max_length=255, null=True, blank=True)
    country = models.CharField(max_length=255, null=True, blank=True,default='Ecuador')
    province = models.CharField(max_length=255, null=True, blank=True)
    
    
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





