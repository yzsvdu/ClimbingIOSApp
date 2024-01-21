from django.urls import path
from . import views

urlpatterns = [
    path('upload_image/', views.upload_image, name='upload_image'),
    path('get_masks_urls/', views.get_binary_masks, name='get_masks_urls'),
    path('get_mask/', views.get_single_mask, name='get_mask')
    # Add more URL patterns as needed
]