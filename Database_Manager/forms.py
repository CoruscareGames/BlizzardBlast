from django import forms
from django.forms import ModelForm
from .models import *

class OrderForm(ModelForm):
    class Meta:
        model = OrderSample
        fields = ('txn', 'date_ordered', 'customer_name', 'milkshake_ordered', 'total')