from django.urls import path
from . import views

urlpatterns = [
    path('report/', views.report, name='manage_report'),
    path('inventory/', views.inventory, name='manage_inventory'),
    path('recipes/', views.recipes, name='manage_recipes'),
    path('schedule/', views.schedule, name='manage_schedule'),
    path('sales_list/', views.sales_list, name='manage_sales_list'),
]
