from django.urls import path
from . import views
from . import api

urlpatterns = [
    path('upload_image/', views.upload_image, name='upload_image'),
    path('zero_pose/', api.returnPose, name='zero_pose')
    # Add more URL patterns as needed
]