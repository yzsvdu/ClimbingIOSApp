import os
import threading
from PIL import Image, ImageDraw

def plot_route_and_instances(route, instances, image_width, image_height, output_file):
    img = Image.new('RGB', (image_width, image_height), color='white')
    draw = ImageDraw.Draw(img)

    # Draw the overall box
    overall_box = [(0, 0), (image_width, image_height)]
    draw.rectangle(overall_box, outline='black')  # Draw rectangle

    # Draw each instance box inside the overall box
    for instance in instances:
        box = instance['box']
        x_min, y_min, x_max, y_max = box['x_min'], box['y_min'], box['x_max'], box['y_max']
        draw.rectangle([x_min, y_min, x_max, y_max], outline='blue')  # Draw rectangle
        draw.text(((x_min + x_max) / 2, (y_min + y_max) / 2), str(instance['mask_number']), fill='black')  # Draw text

    # Ensure the directory structure exists
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    # Save the plot to an image file
    img.save(output_file)

def process_route(route_holds_list, start_holds_list, route_hold_instances, image_width, image_height):
    print(f"working with route: {route_holds_list}")
    print(f"working with start holds: {start_holds_list}")
    print(f"working with instances: {route_hold_instances}")
    print(f"working with width: {image_width}, height: {image_height}")
    output_file = "testing_images/route.png"
    plot_thread = threading.Thread(target=plot_route_and_instances,
                                   args=(route_holds_list, route_hold_instances, 960, 1280, output_file))

    # Start the thread
    plot_thread.start()