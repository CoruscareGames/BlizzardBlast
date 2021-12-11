from django import forms
from django.db.models.base import Model
from django.forms import ModelForm
from django.forms.models import modelform_factory
from .models import *

class SaleForm(ModelForm):
    class Meta:
        model = Sale
        fields = ('customer_name', 'day_date', 'week_date')

class OrdersForm(ModelForm):
    class Meta:
        model = Orders
        fields = ('price',)

class MilkshakeForm(ModelForm):
    class Meta:
        model = Milkshake
        fields = ('recipe_name', 'recipe_size')

class CustomizationForm(ModelForm):
    class Meta:
        model = Customization
        fields = ('ingredient_name', 'ingredient_quantity', 'price_delta')