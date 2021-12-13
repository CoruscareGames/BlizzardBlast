from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from django.views.generic.detail import DetailView
from .models import *
from .forms import *
from .filters import *

# Select views
def report(request):
    sale = Sale.objects.all()
    sale_filter = SaleFilter(request.GET, queryset=sale)
    sale = sale_filter.qs
    context = {
        'sale': sale,
        'sale_filter': sale_filter,
    }

    return render(request, 'Database_Manager/report.html', context)


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


def sale_details(request,txn):
    context = {
        'sale' : Sale.objects.get(pk=txn),
        'orders': Orders.objects.raw('SELECT * FROM orders, sale WHERE sale.txn=orders.txn'),
        'customization': Customization.objects.raw('SELECT * FROM customization,orders,milkshake WHERE orders.milkshake_id=milkshake.milkshake_id AND customization.milkshake_id=milkshake.milkshake_id'),
        'total': Orders.objects.raw('SELECT SUM(price) AS total, orders.txn AS txn FROM orders,sale WHERE orders.txn = sale.txn GROUP BY orders.txn'),
        'milkshake': Milkshake.objects.all(),
        'recipe_price': RecipePrice.objects.raw('SELECT recipe_price.price,recipe_price.recipe_name,recipe_price.recipe_size FROM orders, milkshake,recipe_price WHERE orders.milkshake_id=milkshake.milkshake_id AND recipe_price.recipe_name=milkshake.recipe_name AND recipe_price.recipe_size = milkshake.recipe_size')
    }
    return render (request, 'Database_Manager/sale.html', context)
