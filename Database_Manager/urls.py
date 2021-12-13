from django.urls import path
from . import views

urlpatterns = [
    # path('', views.sales_list, name='sales_list'),
    path('report/', views.report, name='report'),
    path('inventory/', views.inventory, name='inventory'),
    path('recipes/', views.recipes, name='recipes'),
    path('schedule/', views.schedule, name='schedule'),

    path('inventory/create_ingredient', views.create_ingredient, name='create_ingredient'),
    path('inventory/manage/<ingredient_name>', views.manage_ingredient, name='manage_ingredient'),
    path('inventory/delete/<ingredient_name>', views.delete_ingredient, name='delete_ingredient'),
    
    path('sales_list/', views.sales_list, name='sales_list'),
    path('sales_list/<int:txn>', views.sale_details, name='sale_details'),
]
