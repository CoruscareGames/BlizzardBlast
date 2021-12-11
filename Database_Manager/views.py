from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from .models import *
from .forms import *

# Create your views here.
def new_sale(request):
    # form = OrderForm
    # context = {
    #     'form': form, 
    # }
    
    # if request.method == "POST":
    #     form = OrderForm(request.POST)
        
    #     if form.is_valid():
    #         form.save()
    #         return HttpResponseRedirect('/')
            
    return render(request, 'Database_Manager/new_sale.html')

def inventory(request):
    context = {
        'ingredient': Ingredient.objects.all()
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

def schedule(request):
    context = {
        'schedule': Schedule.objects.all()
    }
    return render(request, 'Database_Manager/schedule.html', context)

def sales_list(request):
    context = {
        'sale': Sale.objects.all()
    }
    return render(request, 'Database_Manager/sales_list.html', context)
    