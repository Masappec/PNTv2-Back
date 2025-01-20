from django.db import models

class Pnt1_Pasive(models.Model):
    identification = models.CharField(max_length=50)
    function = models.CharField(max_length=255)
    type = models.CharField(max_length=255)
    establishment_name = models.CharField(max_length=255)
    saip = models.CharField(max_length=255)
    name_solicitant = models.CharField(max_length=255)
    date = models.CharField(max_length=255)
    date_response = models.CharField(max_length=255)
    state = models.CharField(max_length=255)
    
    

class Pnt1_Active(models.Model):
    identification = models.CharField(max_length=50)
    function = models.CharField(max_length=255)
    type = models.CharField(max_length=255)
    establishment_name = models.CharField(max_length=255)
    art = models.CharField(max_length=255)
    numeral = models.CharField(max_length=255)
    enero = models.BooleanField()
    febrero = models.BooleanField()
    marzo = models.BooleanField()
    abril = models.BooleanField()
    mayo = models.BooleanField()
    junio = models.BooleanField()
    julio = models.BooleanField()
    agosto = models.BooleanField()
    

class Pnt1_Colab(models.Model):
    identification = models.CharField(max_length=50)
    function = models.CharField(max_length=255)
    type = models.CharField(max_length=255)
    establishment_name = models.CharField(max_length=255)
    art = models.CharField(max_length=255)
    numeral = models.CharField(max_length=255)
    enero = models.BooleanField()
    febrero = models.BooleanField()
    marzo = models.BooleanField()
    abril = models.BooleanField()
    mayo = models.BooleanField()
    junio = models.BooleanField()
    julio = models.BooleanField()
    agosto = models.BooleanField()


class Pnt1_Focal(models.Model):
    identification = models.CharField(max_length=50)
    function = models.CharField(max_length=255)
    type = models.CharField(max_length=255)
    establishment_name = models.CharField(max_length=255)
    art = models.CharField(max_length=255)
    numeral = models.CharField(max_length=255)
    enero = models.BooleanField()
    febrero = models.BooleanField()
    marzo = models.BooleanField()
    abril = models.BooleanField()
    mayo = models.BooleanField()
    junio = models.BooleanField()
    julio = models.BooleanField()
    agosto = models.BooleanField()


class Pnt1_Reservada(models.Model):
    identification = models.CharField(max_length=50)
    establishment_name = models.CharField(max_length=255)
    classification = models.CharField(max_length=255)
    theme = models.TextField()
    base_legal = models.TextField()
    date_classification = models.CharField(max_length=255)
    period = models.CharField(max_length=255)
    extension = models.CharField(max_length=255)
    description = models.CharField(max_length=255)
    date_extension = models.CharField(max_length=255)
    period_extension = models.CharField(max_length=255)