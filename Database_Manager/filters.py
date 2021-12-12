import django_filters
from django_filters import DateFilter, CharFilter, DateRangeFilter
from .models import *

class SaleFilter(django_filters.FilterSet):
    customer = CharFilter(field_name='customer_name', lookup_expr='icontains')
    range = DateRangeFilter(field_name='day_date')

    class Meta:
        model = Sale
        fields = []
        