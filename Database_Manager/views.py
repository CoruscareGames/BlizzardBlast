from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from django.views.generic.detail import DetailView 
from .models import *
from .forms import *

# Select views
def new_sale(request):
    return render(request, 'Database_Manager/new_sale.html')


# List views
def inventory(request):
    context = {
        'ingredient': Ingredient.objects.raw(''' SELECT	ingredient_name, 
                                                        category,
                                                        stock
                                                FROM	ingredient
                                                ORDER BY stock, ingredient_name''')
    }
    return render(request, 'Database_Manager/inventory.html', context)


def sales_list(request):
    context = {
        'sale': Sale.objects.all().order_by('-txn')
    }
    return render(request, 'Database_Manager/sales_list.html', context)


def recipes(request):
    context = {
        'recipe': Recipe.objects.all(),
        'recipe_size': RecipeSize.objects.all(),
        'recipe_price': RecipePrice.objects.all(),
        'servings': Servings.objects.all(),
        'servingsA': Servings.objects.raw('SELECT DISTINCT ingredient_name, recipe_name, recipe_size, servings FROM Servings'),
    }
    return render(request, 'Database_Manager/recipes.html', context)


def schedule(request):
    context = {
        'schedule': Schedule.objects.all(),
        'manager': Manager.objects.all(),
        'week': Week.objects.all(),
    }
    return render(request, 'Database_Manager/schedule.html', context)

# detail view for each individual sale
class sale(DetailView):
    model = Sale
    template_name = 'Database_Manager/sale.html'
