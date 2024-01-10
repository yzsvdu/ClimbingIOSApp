# views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

@csrf_exempt
def upload_image(request):
    if request.method == 'POST' and request.FILES['image']:
        image = request.FILES['image']
        # You can process the image here (e.g., save it to a specific location, perform image processing, etc.)
        filename = default_storage.save('uploaded_images/' + image.name, ContentFile(image.read()))

        # Return a JSON response
        return JsonResponse({'message': 'Image uploaded successfully', 'filename': filename})
    else:
        return JsonResponse({'message': 'Invalid request method or no image provided'}, status=400)
