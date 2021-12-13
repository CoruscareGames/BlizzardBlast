from django.shortcuts import render, redirect
from django.http import HttpResponse, HttpResponseRedirect
from django.contrib import messages
from django.db import connection

from .models import *
from .forms import *
from .filters import *

# Ingredient forms
def create_ingredient(request):
    form = IngredientFormCreate()
    update = False
    context = {
        'form': form,
        'update': update,
    }

    if request.method == 'POST':
        form = IngredientFormCreate(request.POST)

        if form.is_valid():
            form.save()
            return redirect('inventory')

    return render(request, 'Database_Manager/ingredient.html', context)


def manage_ingredient(request, ingredient_name):
    ingredient = Ingredient.objects.get(pk=ingredient_name)
    form = IngredientFormUpdate(request.POST or None, instance=ingredient)
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


# Sale forms
def create_milkshake(request):
    formMilkshake = MilkshakeForm()
    context = {
        'formMilkshake': formMilkshake,
    }

    print(request.POST)

    if request.method == 'POST':

        formMilkshake = MilkshakeForm(request.POST)

        if formMilkshake.is_valid():

            formMilkshakeCleaned = formMilkshake.cleaned_data
            connection.cursor().execute(
                "INSERT INTO milkshake VALUES (DEFAULT, %(name)s, %(size)s)",
                {
                    "name": str(formMilkshakeCleaned["recipe_name"]),
                    "size": formMilkshakeCleaned["recipe_size"].recipe_size
                }
            )

            return redirect('sales_list')

    return render(request, 'Database_Manager/new_milkshake.html', context)


def create_customization(request):
    formCustomization = CustomizationForm()
    context = {
        'formCustomization': formCustomization,
    }

    if request.method == 'POST':

        formCustomization = CustomizationForm(request.POST)

        if formCustomization.is_valid():

            formCustomizationCleaned = formCustomization.cleaned_data
            milkshake = formCustomizationCleaned["milkshake"]

            # Get all Serving rows that match this recipe name, size, and ingredient
            recipe_ingredients = Servings.objects.filter(
                recipe_name=milkshake.recipe_name,
                recipe_size=milkshake.recipe_size,
                ingredient_name=str(formCustomizationCleaned["ingredient_name"])
            )

            # Should theoretically be a 1 element List
            # Or an empty one.
            recipe_ingredients = [{"name": i.recipe_name, "servings": i.servings} for i in recipe_ingredients]

            if not recipe_ingredients and formCustomizationCleaned["ingredient_quantity"] < 0:
                messages.error(request, 'That was an invalid move')
                return render(request, 'Database_Manager/new_customization.html', context)

            if recipe_ingredients and recipe_ingredients[0]["servings"] + formCustomizationCleaned["ingredient_quantity"] < 0:
                messages.error(request, 'That was an invalid move')
                return render(request, 'Database_Manager/new_customization.html', context)


            connection.cursor().execute(
                '''INSERT INTO customization
                    VALUES
                    (
                        %(milkshake)s,
                        %(ingredient)s,
                        %(serving)s,
                        (
                            SELECT price_per_serving
                            FROM ingredient
                            WHERE ingredient_name = %(ingredient)s
                        ) * %(serving)s
                    );
                ''',
                {
                    "milkshake": milkshake.milkshake_id,
                    "ingredient": str(formCustomizationCleaned["ingredient_name"]),
                    "serving": formCustomizationCleaned["ingredient_quantity"]
                }
            )

            return redirect('sales_list')

    return render(request, 'Database_Manager/new_customization.html', context)


def create_sale(request):
    formSale = SaleForm()
    context = {
        'formSale': formSale,
    }

    if request.method == 'POST':

        formSale = SaleForm(request.POST)

        if formSale.is_valid():

            formSaleCleaned = formSale.cleaned_data
            connection.cursor().execute(
                '''INSERT INTO sale
                    VALUES
                    (
                        DEFAULT,
                        %(customer)s,
                        %(daydate)s,
                        (
                        SELECT week_date
                        FROM week
                        WHERE %(daydate)s BETWEEN week_date AND (week_date + INTERVAL '6 days'
                        ))
                    );
                ''',
                {
                    "customer": str(formSaleCleaned["customer_name"]),
                    "daydate": formSaleCleaned["day_date"]
                }
            )

            return redirect('sales_list')

    return render(request, 'Database_Manager/new_sale.html', context)


def create_orders(request):
    formOrders = OrdersForm()
    context = {
        'formOrders': formOrders,
    }

    if request.method == 'POST':

        formOrders = OrdersForm(request.POST)

        if formOrders.is_valid():

            formOrdersCleaned = formOrders.cleaned_data
            connection.cursor().execute(
                '''INSERT INTO orders
                    VALUES
                    (
                        %(txn)s,
                        %(milkshake)s,
                        (
                            SELECT SUM(price) FROM
                            (
                                SELECT price
                                FROM recipe_price
                                WHERE recipe_name = (
                                    SELECT recipe_name
                                    FROM milkshake
                                    WHERE milkshake_id = %(milkshake)s
                                )
                                AND recipe_size = (
                                    SELECT recipe_size
                                    FROM milkshake
                                    WHERE milkshake_id = %(milkshake)s
                                )
                                UNION ALL
                                SELECT price_delta
                                FROM customization
                                WHERE milkshake_id = %(milkshake)s
                            )
                            AS foo
                        )
                    );
                ''',
                {
                    "txn": formOrdersCleaned["txn"].txn,
                    "milkshake": formOrdersCleaned["milkshake"].milkshake_id
                }
            )

            return redirect('sales_list')

    return render(request, 'Database_Manager/new_order.html', context)


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
        'total': Orders.objects.raw('SELECT SUM(price) AS total, orders.txn AS txn FROM orders,sale WHERE orders.txn = sale.txn GROUP BY orders.txn'),
        'milkshake': Milkshake.objects.all(),
        'recipe_price': RecipePrice.objects.raw('SELECT DISTINCT recipe_price.price,recipe_price.recipe_name,recipe_price.recipe_size FROM orders, milkshake,recipe_price WHERE orders.milkshake_id=milkshake.milkshake_id AND recipe_price.recipe_name=milkshake.recipe_name AND recipe_price.recipe_size = milkshake.recipe_size')
    }
    return render (request, 'Database_Manager/sale.html', context)
