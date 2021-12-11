from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from .models import *
from .forms import *

# Select views
def new_sale(request):
    return render(request, 'Database_Manager/new_sale.html')


# List views
def inventory(request):
    context = {
        'ingredient': Ingredient.objects.all().order_by('category', 'ingredient_name')
    }
    return render(request, 'Database_Manager/inventory.html', context)

def recipes(request):
    context = {
        'recipe': RecipePrice.objects.all()
    }
    return render(request, 'Database_Manager/recipes.html', context)

def employees(request):
    context = {
        'employee': Employee.objects.all()
    }
    return render(request, 'Database_Manager/employees.html', context)

def sales_list(request):
    context = {
        'sale': Sale.objects.all().order_by('-txn')
    }
    return render(request, 'Database_Manager/sales_list.html', context)

def schedule(request):
    context = {
        'schedule': Schedule.objects.all(),
        'employee': Employee.objects.all(),
        'manager': Manager.objects.all(),
        'week': Week.objects.all(),
    }
    return render(request, 'Database_Manager/schedule.html', context)