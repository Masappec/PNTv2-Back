
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
    
    