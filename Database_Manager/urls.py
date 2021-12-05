from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='manage_home'),
    path('inventory/', views.inventory, name='manage_inventory'),
    path('recipes/', views.recipes, name='manage_recipes'),
    path('employees/', views.employees, name='manage_employees'),
    path('schedule/', views.schedule, name='manage_schedule'),
    path('sales/', views.sales, name='manage_sales'),
]
