from django.shortcuts import render
from django.http import HttpResponse

# Create your views here.
def home(request):
    return render(request, 'Database_Manager/new_sale.html')

def inventory(request):
    return render(request, 'Database_Manager/inventory.html')

def recipes(request):
    return render(request, 'Database_Manager/recipes.html')

def employees(request):
    return render(request, 'Database_Manager/employees.html')

def schedule(request):
    return render(request, 'Database_Manager/schedule.html')

def sales_list(request):
    return render(request, 'Database_Manager/sales_list.html')