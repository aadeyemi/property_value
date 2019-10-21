# pylint: disable=import-error,bad-option-value
from django.shortcuts import render
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.decorators import permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny

from .harris.hcad_views import hcad_views

import json


@api_view()
@permission_classes((AllowAny,))
def account_by_id(request, county, account):
    """
    get harris county property by account number
    """
    if county == "tx_harris":
        data = hcad_views("account", account)
        output = {"output": data, "status": "success"}
        status_out = status.HTTP_200_OK
    else:
        output = {"msg": "county not found", "status": "error"}
        status_out = status.HTTP_404_NOT_FOUND

    return Response(output, status=status_out)


@api_view()
@permission_classes((AllowAny,))
def account_by_addr(request, county, str_addr):
    """
    get harris county property by street address
    """
    if county == "tx_harris":
        data = hcad_views("address", str_addr)
        output = {"output": data, "status": "success"}
        status_out = status.HTTP_200_OK
    else:
        output = {"msg": "county not found", "status": "error"}
        status_out = status.HTTP_404_NOT_FOUND

    return Response(output, status=status_out)
