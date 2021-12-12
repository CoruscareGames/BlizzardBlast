from django import forms
from django.db.models.base import Model
from django.forms import ModelForm
from django.forms.models import modelform_factory
from .models import *

class IngredientForm(ModelForm):
    class Meta:
        model = Ingredient
        fields = ('ingredient_name', 'category', 'stock', 'price_per_serving',)
        lbales = {
            'ingredient_name': 'Ingredient Name',
            'category': 'Category',
            'stock': 'Quantity',
            'price_per_serving': 'Price Per Serving',
        }
