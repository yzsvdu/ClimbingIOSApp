from django.urls import path
from . import views

urlpatterns = [
    path('upload_image/', views.upload_image, name='upload_image'),
    # Add more URL patterns as needed
]