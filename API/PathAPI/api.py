from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .DTOModels.PoseDTO import PoseDTO


@csrf_exempt
def returnPose(request):
    zero_pose_instance = PoseDTO(
        nose=[0, 0],
        neck=[0, 0],
        right_shoulder=[0, 0],
        right_elbow=[0, 0],
        right_wrist=[0, 0],
        left_shoulder=[0, 0],
        left_elbow=[0, 0],
        left_wrist=[0, 0],
        right_hip=[0, 0],
        right_knee=[0, 0],
        right_ankle=[0, 0],
        left_hip=[0, 0],
        left_knee=[0, 0],
        left_ankle=[0, 0],
        right_eye=[0, 0],
        left_eye=[0, 0],
        right_ear=[0, 0],
        left_ear=[0, 0],
    )

    # Convert PoseDTO instance to a dictionary
    pose_dict = {
        "attributes": zero_pose_instance.attributes
    }

    # Return the JSON response
    return JsonResponse(pose_dict)
