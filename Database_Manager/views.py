from django.shortcuts import render
from django.http import HttpResponse

# Create your views here.
def home(request):
    return HttpResponse('Homepage')

def inventory(request):
    return HttpResponse('Inventory Page')

def recipes(request):
    return HttpResponse('Base Recipes Page')

def employees(request):
    return HttpResponse('Employees Page')

def schedule(request):
    return HttpResponse('Schedule Page')

def sales(request):
    return HttpResponse('Past Sales Page')