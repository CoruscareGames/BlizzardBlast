from django import forms
from django.db.models.base import Model
from django.forms import ModelForm
from django.forms.models import modelform_factory
from .models import *

class IngredientFormCreate(ModelForm):
    class Meta:
        model = Ingredient
        fields = ('ingredient_name', 'category', 'stock', 'price_per_serving',)
        labels = {
            'ingredient_name': 'Ingredient Name',
            'category': 'Category',
            'stock': 'Quantity',
            'price_per_serving': 'Price Per Serving',
        }


class IngredientFormUpdate(ModelForm):
    class Meta:
        model = Ingredient
        fields = ('category', 'stock', 'price_per_serving',)
        labels = {
            'category': 'Category',
            'stock': 'Quantity',
            'price_per_serving': 'Price Per Serving',
        }

class SaleForm(ModelForm):
    class Meta:
        model = Sale
        fields = ('customer_name', 'day_date', 'week_date')
        labels = {
            'customer_name': 'Customer Name',
            'day_date': 'Date',
            'week_date': 'Week',
        }


class CustomizationForm(ModelForm):
    class Meta:
        model = Customization
        fields = ('milkshake', 'ingredient_name', 'ingredient_quantity')
        labels = {
            'milkshake': 'Milkshake',
            'ingredient_name': 'Ingredients',
            'ingredient_quantity': 'Quantity'
        }


class MilkshakeForm(ModelForm):
    class Meta:
        model = Milkshake
        fields = ('recipe_name', 'recipe_size')
        labels = {
            'recipe_name': 'Recipe',
            'recipe_size': 'Size',
        }


class OrdersForm(ModelForm):
    class Meta:
        model = Orders
        fields = ('txn', 'milkshake',)
        labels = {
            'txn': 'TXN',
            'milkshake': 'Milkshake',
        }