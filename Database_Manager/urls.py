from django.urls import path
from . import views

urlpatterns = [
    path('', views.new_sale, name='manage_home'),
    path('inventory/', views.inventory, name='manage_inventory'),
    path('recipes/', views.recipes, name='manage_recipes'),
    path('schedule/', views.schedule, name='manage_schedule'),
    path('sales_list/', views.sales_list, name='manage_sales_list'),
    path('sales_list/<int:txn>', views.sale_details, name='sale_details'),
]
