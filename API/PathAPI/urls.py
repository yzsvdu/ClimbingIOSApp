from django.urls import path
from . import api

urlpatterns = [
    path('upload_image/', api.upload_image, name='upload_image'),
    path('get_mask/', api.get_single_mask, name='get_mask')
    # Add more URL patterns as needed
]