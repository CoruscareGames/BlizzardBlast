from django.db import models
from django.db.models.fields import DateField
from django.utils import timezone

# Create your models here.
class OrderSample(models.Model):
    txn = models.BigAutoField(primary_key=True)
    date_ordered = models.DateTimeField(default=timezone.now)
    customer_name = models.CharField(max_length=255)
    milkshake_choices = [
        ('MANGO', 'Mango Manza'),
        ('STRAWBERRY', 'Strawberry Carry'),
        ('OREO', 'Ore-ion'),
        ('CHOCOLATE', 'Tsokolate'),
    ]
    milkshake_ordered = models.CharField(blank=True, max_length=50, choices=milkshake_choices)
    total = models.IntegerField()

    def __str__(self):
        return self.customer_name