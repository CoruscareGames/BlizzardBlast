from django import forms
from django.db.models.base import Model
from django.forms import ModelForm
from django.forms.models import modelform_factory
from .models import *

class IngredientForm(ModelForm):
    class Meta:
        model = Ingredient
        fields = ('ingredient_name', 'category', 'stock', 'price_per_serving',)
        labels = {
            'ingredient_name': 'Ingredient Name',
            'category': 'Category',
            'stock': 'Quantity',
            'price_per_serving': 'Price Per Serving',
        }


class SaleForm(ModelForm):
    class Meta:
        model = Sale
        fields = ('customer_name', 'day_date')
        labels = {
            'customer_name': 'Customer Name',
            'day_date': 'Date',
        }


class CustomizationForm(ModelForm):
    class Meta:
        model = Customization
        fields = ('milkshake', 'ingredient_name', 'ingredient_quantity', 'price_delta')
        labels = {
            'milkshake': 'Milkshake',
            'ingredient_name': 'Ingredients',
            'ingredient_quantity': 'Quantity',
            'price_delta': 'Price',
        }


class MilkshakeForm(ModelForm):
    class Meta:
        model = Milkshake
        fields = ('recipe_name', 'recipe_size')
        labels = {
            'recipe_name': 'Recipe',
            'recipe_size': 'Size',
        }