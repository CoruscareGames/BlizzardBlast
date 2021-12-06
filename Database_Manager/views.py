from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from .models import *
from .forms import *

# Create your views here.
def new_sale(request):
    form = OrderForm
    context = {
        'form': form, 
    }
    
    if request.method == "POST":
        form = OrderForm(request.POST)
        
        if form.is_valid():
            form.save()
            return HttpResponseRedirect('/')
            
    return render(request, 'Database_Manager/new_sale.html', context)

def inventory(request):
    return render(request, 'Database_Manager/inventory.html')

def recipes(request):
    return render(request, 'Database_Manager/recipes.html')

def employees(request):
    return render(request, 'Database_Manager/employees.html')

def schedule(request):
    return render(request, 'Database_Manager/schedule.html')

def sales_list(request):
    context = {
        'sales': OrderSample.objects.all()
    }
    return render(request, 'Database_Manager/sales_list.html', context)
    