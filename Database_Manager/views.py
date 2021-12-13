from django.shortcuts import render, redirect
from django.http import HttpResponse, HttpResponseRedirect
from .models import *
from .forms import *
from .filters import *

# Form views
def create_ingredient(request):
    form = IngredientForm()
    update = False
    context = {
        'form': form,
        'update': update,
    }

    if request.method == 'POST':
        form = IngredientForm(request.POST)
        
        if form.is_valid():
            form.save()
            return redirect('inventory')
            
    return render(request, 'Database_Manager/ingredient.html', context)


def manage_ingredient(request, ingredient_name):
    ingredient = Ingredient.objects.get(pk=ingredient_name)
    form = IngredientForm(request.POST or None, instance=ingredient)
    update = True
    context = {
        'ingredient': ingredient,
        'form': form,
        'update': update,
    }

    if form.is_valid():
        form.save()
        return redirect('inventory')

    return render(request, 'Database_Manager/ingredient.html', context)


def delete_ingredient(request, ingredient_name):
    ingredient = Ingredient.objects.get(pk=ingredient_name)
    ingredient.delete()
    
    return redirect('inventory')


def create_milkshake(request):
    formMilkshake = MilkshakeForm()
    context = {
        'formMilkshake': formMilkshake,
    }

    if request.method == 'POST':
        formMilkshake = MilkshakeForm(request.POST)
        
        if formMilkshake.is_valid():
            formMilkshake.save()
            return redirect('sales_list')
            
    return render(request, 'Database_Manager/new_sale.html', context)


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


def sale_details(request,txn):
    context = {
        'sale' : Sale.objects.get(pk=txn),
        'orders': Orders.objects.raw('SELECT * FROM orders, sale WHERE sale.txn=orders.txn'),
        'customization': Customization.objects.raw('SELECT * FROM customization,orders,milkshake WHERE orders.milkshake_id=milkshake.milkshake_id AND customization.milkshake_id=milkshake.milkshake_id'),
        #'total': Orders.objects.raw('SELECT SUM(price) AS total FROM orders,sale WHERE orders.txn=sale.txn'),
        'milkshake': Milkshake.objects.all(),
        'recipe_price': RecipePrice.objects.raw('SELECT recipe_price.price,recipe_price.recipe_name,recipe_price.recipe_size FROM orders, milkshake,recipe_price WHERE orders.milkshake_id=milkshake.milkshake_id AND recipe_price.recipe_name=milkshake.recipe_name AND recipe_price.recipe_size = milkshake.recipe_size')
    }
    return render (request, 'Database_Manager/sale.html', context)

    #model = Sale
    #template_name = 'Database_Manager/sale.html'