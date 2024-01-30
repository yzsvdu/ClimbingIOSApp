import cv2
import numpy as np
from collections import defaultdict
from scipy.spatial import distance
import os


def get_average_color(image_path):
    image = cv2.imread(image_path)
    average_color = np.mean(image, axis=(0, 1))
    return tuple(map(int, average_color))


def generate_main_colors():
    main_colors = {}
    segments_per_channel = 9
    step_size = 256 // segments_per_channel
    # Generate main colors
    for r in range(0, 256, step_size):
        for g in range(0, 256, step_size):
            for b in range(0, 256, step_size):
                color_name = f"{r}-{g}-{b}"
                main_colors[color_name] = (r, g, b)

    return main_colors


def categorize_color(color):
    main_colors = generate_main_colors()
    closest_color = min(main_colors, key=lambda x: distance.euclidean(color, main_colors[x]))
    return closest_color


def sort_by_color(image_folder):
    color_hold_mapping = defaultdict(list)
    for filename in os.listdir(image_folder):
        if filename.endswith(".png"):
            image_path = os.path.join(image_folder, filename)
            color = get_average_color(image_path)
            color_rgb = tuple(reversed(color))
            color_category = categorize_color(color_rgb)
            color_hold_mapping[color_category].append(int((filename.replace("mask_", "").replace(".png", ""))))

    return color_hold_mapping

def get_routes(hold_image_folder):
    routes = sort_by_color(hold_image_folder)
    return routes