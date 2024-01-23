 # views.py
import json
import os
import uuid

from django.http import JsonResponse
from django.http import HttpResponseNotFound, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import cv2
import numpy as np
from detectron2.utils.visualizer import Visualizer
from .apps import PathAPIConfig
from detectron2.data import MetadataCatalog

@csrf_exempt
def upload_image(request):
    if request.method == 'POST' and request.FILES['image']:
        # Generate a unique folder name using UUID
        unique_folder_name = str(uuid.uuid4())
        unique_folder_path = os.path.join("processed_requests", unique_folder_name)
        os.makedirs(unique_folder_path, exist_ok=True)

        image = request.FILES['image']

        content = image.read()

        original_image_path = os.path.join(unique_folder_path, "original_image.jpg")
        with open(original_image_path, 'wb') as original_image_file:
            original_image_file.write(content)

        img_np = np.frombuffer(content, dtype=np.uint8)
        img = cv2.imdecode(img_np, cv2.IMREAD_COLOR)
        outputs = PathAPIConfig.predictor(img)
        instances = outputs["instances"].to("cpu")

        # Filter out holds below 80% confidence
        confidence_threshold = 0.8
        selected_indices = instances.scores >= confidence_threshold
        filtered_instances = instances[selected_indices]

        MetadataCatalog.get("meta").thing_classes = ["hold", "volume"]
        metadata = MetadataCatalog.get("meta")

        # Visualize the filtered holds
        v = Visualizer(
            img[:, :, ::-1],
            metadata=metadata
        )

        out_predictions = v.draw_instance_predictions(filtered_instances)
        img_holds = out_predictions.get_image()

        # Save the image with the same size and resolution as the original image
        output_file_path = os.path.join(unique_folder_path, "detected_holds.png")
        cv2.imwrite(output_file_path, img_holds)

        # Save binary masks as separate image files within the unique folder
        masks_folder_path = os.path.join(unique_folder_path, "binary_masks")
        os.makedirs(masks_folder_path, exist_ok=True)

        instances = []

        for i in range(len(filtered_instances)):
            binary_mask = filtered_instances.pred_masks.numpy()[i]
            mask_file_path = os.path.join(masks_folder_path, f"binary_mask_{i}.png")
            cv2.imwrite(mask_file_path, binary_mask.astype(np.uint8) * 255)

            box_data = {key: float(value) for key, value in zip(['x_min', 'y_min', 'x_max', 'y_max'], filtered_instances.pred_boxes.tensor.numpy()[i])}
            instance_data = {'box': box_data, 'mask_number': i}
            instances.append(instance_data)

        response_data = {'instances': instances, 'folder_path': unique_folder_name}
        return JsonResponse(response_data)

    else:
        return JsonResponse({'message': 'Invalid request method or no image provided'}, status=400)


def get_binary_masks(request):
    unique_folder_name = request.GET.get('folder_path', None)

    if unique_folder_name:
        masks_folder_path = os.path.join("processed_requests", unique_folder_name, "binary_masks")

        if os.path.exists(masks_folder_path):
            mask_urls = []

            for filename in os.listdir(masks_folder_path):
                if filename.endswith(".png"):
                    mask_url = request.build_absolute_uri(os.path.join(masks_folder_path, filename))
                    mask_urls.append(mask_url)

            response_data = {'urls': mask_urls}
            return JsonResponse(response_data)
        else:
            return JsonResponse({'message': 'Binary masks folder not found'}, status=404)
    else:
        return JsonResponse({'message': 'Unique folder name not provided in the request'}, status=400)


def get_single_mask(request):
    folder_path = request.GET.get('folder_path', None)
    mask_number = request.GET.get('mask_number', None)

    if folder_path and mask_number:
        masks_folder_path = os.path.join("processed_requests", folder_path, "binary_masks")
        mask_filename = f"binary_mask_{mask_number}.png"
        mask_file_path = os.path.join(masks_folder_path, mask_filename)

        if os.path.exists(mask_file_path):
            with open(mask_file_path, 'rb') as file:
                file_content = file.read()
                response = HttpResponse(file_content, content_type='image/png')
                return response
        else:
            return HttpResponseNotFound('Mask not found')
    else:
        return HttpResponseNotFound('Folder path or mask number not provided in the request')