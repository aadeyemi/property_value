"""
app url definitions
"""
from django.urls import path, re_path
from rest_framework.authtoken import views as rest_framework_views

from property_value_app.harris import hcad_views

urlpatterns = [  # pylint: disable-msg=C0103
    # hcad views
    path('real-acct/<str:state>/<str:county>/<int:account>/',
         hcad_views.get_prop_by_acct),
]
