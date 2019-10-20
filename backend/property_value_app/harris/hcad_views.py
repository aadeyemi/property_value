from django.shortcuts import render
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.decorators import permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny

# Create your views here.


@api_view()
@permission_classes((AllowAny,))
def get_prop_by_acct(request, state, county, account):
    """
    get texas hcad property by real account number
    """
    output = str(state) + str(county) + str(account)
    return Response(output, status=status.HTTP_200_OK)
