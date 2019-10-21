# pylint: disable=import-error,bad-option-value
"""
app url definitions
"""
from django.urls import path, re_path
from rest_framework.authtoken import views as rest_framework_views

from property_value_app import views_search

urlpatterns = [
    path('acct/<str:county>/<int:account>/', views_search.account_by_id),
    path('addr/<str:county>/<str:str_addr>/', views_search.account_by_addr),
]
