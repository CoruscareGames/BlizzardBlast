from django.urls import path
from . import views

urlpatterns = [
    path('report/', views.report, name='report'),
    path('inventory/', views.inventory, name='inventory'),
    path('recipes/', views.recipes, name='recipes'),
    path('schedule/', views.schedule, name='schedule'),
    path('', views.sales_list, name='sales_list'),
    path('inventory/create_ingredient', views.create_ingredient, name='create_ingredient'),
    path('inventory/<ingredient_name>', views.manage_ingredient, name='manage_ingredient'),
]
