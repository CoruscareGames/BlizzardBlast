from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from .models import *
from .forms import *

# Form views



# Select views
def report(request):
    context = {
        'milkshake': Milkshake.objects.raw('''SELECT	recipe_name,
                                                    COUNT(recipe_name)
                                            FROM	milkshake
                                            INNER JOIN orders on milkshake.milkshake_id = orders.milkshake_id
                                            INNER JOIN sale on orders.txn = sale.txn
                                            WHERE	week_date BETWEEN '2021-12-06' AND '2021-12-12'
                                            GROUP BY recipe_name
                                            ORDER BY COUNT(recipe_name) DESC        
                                            ''')
    }
    return render(request, 'Database_Manager/report.html', context)


# List views
def sales_list(request):
    context = {
        'sale': Sale.objects.all().order_by('-txn')
    }
    return render(request, 'Database_Manager/sales_list.html', context)

def inventory(request):
    context = {
        'ingredient': Ingredient.objects.raw(''' SELECT	ingredient_name, 
                                                        category,
                                                        stock
                                                FROM	ingredient
                                                ORDER BY stock, ingredient_name''')
    }
    return render(request, 'Database_Manager/inventory.html', context)


def recipes(request):
    context = {
        'recipe': Recipe.objects.all(),
        'recipe_size': RecipeSize.objects.all(),
        'recipe_price': RecipePrice.objects.all(),
        'servings': Servings.objects.all(),
        'servings_ingredients': Servings.objects.raw('SELECT DISTINCT ingredient_name, recipe_name FROM Servings'),
        'servings_size': Servings.objects.raw('SELECT ingredient_name, servings, recipe_size, recipe_name FROM Servings'),
        
    }
    return render(request, 'Database_Manager/recipes.html', context)


def schedule(request):
    context = {
        'schedule': Schedule.objects.all(),
        'manager': Manager.objects.all(),
        'week': Week.objects.all(),
    }
    return render(request, 'Database_Manager/schedule.html', context)