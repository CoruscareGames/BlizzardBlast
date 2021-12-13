from django.urls import path
from . import views

urlpatterns = [
    # path('', views.sales_list, name='sales_list'),
    path('', views.report, name='report'),
    path('inventory/', views.inventory, name='inventory'),
    path('recipes/', views.recipes, name='recipes'),
    path('schedule/', views.schedule, name='schedule'),

    path('inventory/create_ingredient', views.create_ingredient, name='create_ingredient'),
    path('inventory/manage/<ingredient_name>', views.manage_ingredient, name='manage_ingredient'),
    path('inventory/delete/<ingredient_name>', views.delete_ingredient, name='delete_ingredient'),
    
    path('sales_list/', views.sales_list, name='sales_list'),
    path('sales_list/<int:txn>', views.sale_details, name='sale_details'),

    # path('sales_list/new_sale', views.create_sale, name='sale_create'),
    path('sales_list/new_milkshake', views.create_milkshake, name='sale_milkshake'),
    path('sales_list/new_customization', views.create_customization, name='sale_customization'),
    path('sales_list/new_sale', views.create_sale, name='sale_sale'),
    path('sales_list/new_order', views.create_orders, name='sale_orders'),


]
