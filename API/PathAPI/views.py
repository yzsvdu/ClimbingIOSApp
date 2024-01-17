# views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import cv2
import numpy as np
from .DTOModels.PoseDTO import PoseDTO
import argparse


@csrf_exempt
def upload_image(request):
    if request.method == 'POST' and request.FILES['image']:
        image = request.FILES['image']
        # You can process the image here (e.g., save it to a specific location, perform image processing, etc.)
        filename = default_storage.save('uploaded_images/' + image.name, ContentFile(image.read()))
        pose_instance = process_image(filename)
        pose_dict = {
            "attributes": pose_instance.attributes
        }
        # Return the JSON response
        return JsonResponse(pose_dict)
    else:
        return JsonResponse({'message': 'Invalid request method or no image provided'}, status=400)


def process_image(image):
    # parser = argparse.ArgumentParser(description='Run keypoint detection')
    # parser.add_argument("--device", default="cpu", help="Device to inference on")
    # parser.add_argument("--image_file", default="single.jpeg", help="Input image")

    # args = parser.parse_args()
    protoFile = "PathAPI/pose/coco/pose_deploy_linevec.prototxt"
    weightsFile = "PathAPI/pose/coco/pose_iter_440000.caffemodel"
    nPoints = 18
    POSE_PAIRS = [[1, 0], [1, 2], [1, 5], [2, 3], [3, 4], [5, 6], [6, 7], [1, 8], [8, 9], [9, 10], [1, 11], [11, 12],
                  [12, 13], [0, 14], [0, 15], [14, 16], [15, 17]]
    frame = cv2.imread(image)
    frameCopy = np.copy(frame)
    frameWidth = frame.shape[1]
    frameHeight = frame.shape[0]
    threshold = 0.1
    net = cv2.dnn.readNetFromCaffe(protoFile, weightsFile)
    # if args.device == "cpu":
    #     net.setPreferableBackend(cv2.dnn.DNN_TARGET_CPU)
    #     print("Using CPU device")
    # elif args.device == "gpu":
    #     net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
    #     net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
    #     print("Using GPU device")

    inWidth = 368
    inHeight = 368
    inpBlob = cv2.dnn.blobFromImage(frame, 1.0 / 255, (inWidth, inHeight),
                                    (0, 0, 0), swapRB=False, crop=False)
    net.setInput(inpBlob)
    output = net.forward()
    H = output.shape[2]
    W = output.shape[3]

    # Empty list to store the detected keypoints
    points = []

    for i in range(nPoints):
        # confidence map of corresponding body's part.
        probMap = output[0, i, :, :]

        # Find global maxima of the probMap.
        minVal, prob, minLoc, point = cv2.minMaxLoc(probMap)

        # Scale the point to fit on the original image
        x = (frameWidth * point[0]) / W
        y = (frameHeight * point[1]) / H

        if prob > threshold:
            cv2.circle(frameCopy, (int(x), int(y)), 8, (0, 255, 255), thickness=-1, lineType=cv2.FILLED)
            cv2.putText(frameCopy, "{}".format(i), (int(x), int(y)), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2,
                        lineType=cv2.LINE_AA)

            # Add the point to the list if the probability is greater than the threshold
            points.append((int(x), int(y)))
        else:
            points.append((-1, -1))

    # TESTING print out the right wrist:
    # print("RIGHT WRIST = ", points[4][0], points[4][1])

    # create PoseDTO object
    pose_instance = PoseDTO(
        nose=[points[0][0], points[0][1]],
        neck=[points[1][0], points[1][1]],
        right_shoulder=[points[2][0], points[2][1]],
        right_elbow=[points[3][0], points[3][1]],
        right_wrist=[points[4][0], points[4][1]],
        left_shoulder=[points[5][0], points[5][1]],
        left_elbow=[points[6][0], points[6][1]],
        left_wrist=[points[7][0], points[7][1]],
        right_hip=[points[8][0], points[8][1]],
        right_knee=[points[9][0], points[9][1]],
        right_ankle=[points[10][0], points[10][1]],
        left_hip=[points[11][0], points[11][1]],
        left_knee=[points[12][0], points[12][1]],
        left_ankle=[points[13][0], points[13][1]],
        right_eye=[points[14][0], points[14][1]],
        left_eye=[points[15][0], points[15][1]],
        right_ear=[points[16][0], points[16][1]],
        left_ear=[points[17][0], points[17][1]]

    )

    # Draw Skeleton
    # for pair in POSE_PAIRS:
    #     partA = pair[0]
    #     partB = pair[1]
    #
    #     if points[partA] and points[partB]:
    #         cv2.line(frame, points[partA], points[partB], (0, 255, 255), 2)
    #         cv2.circle(frame, points[partA], 8, (0, 0, 255), thickness=-1, lineType=cv2.FILLED)

    cv2.imwrite('uploaded_images/Output-Keypoints.jpg', frameCopy)
    # cv2.imwrite('uploaded_images/Output-Skeleton.jpg', frame)
    #
    # cv2.waitKey(0)

    # Convert PoseDTO instance to a dictionary
    return pose_instance;
