import cv2
import os
def apply_mask_to_image(original_image_path, masks_directory, output_directory):
    # Create the output directory if it doesn't exist
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    # Load the original image
    original_image = cv2.imread(original_image_path)

    if original_image is None:
        print(f"Error: Unable to read the image at '{original_image_path}'")
        return

    # Iterate through each binary mask in the directory
    for mask_filename in os.listdir(masks_directory):
        mask_path = os.path.join(masks_directory, mask_filename)

        # Load the binary mask
        mask = cv2.imread(mask_path, cv2.IMREAD_GRAYSCALE)

        if mask is None:
            print(f"Error: Unable to read the mask at '{mask_path}'")
            continue

        # Find contours in the mask
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        # Find the bounding box that encloses the contours
        if contours:
            bounding_box = cv2.boundingRect(contours[0])

            # Crop the original image to the bounding box
            cropped_image = original_image[bounding_box[1]:bounding_box[1] + bounding_box[3],
                            bounding_box[0]:bounding_box[0] + bounding_box[2]]

            # Create a mask for the cropped region
            cropped_mask = mask[bounding_box[1]:bounding_box[1] + bounding_box[3],
                           bounding_box[0]:bounding_box[0] + bounding_box[2]]

            # Create a 4-channel image with transparency
            rgba_image = cv2.cvtColor(cropped_image, cv2.COLOR_BGR2BGRA)

            # Set the alpha channel based on the cropped mask
            rgba_image[:, :, 3] = cropped_mask

            # Save the resulting cropped and resized image with transparency
            output_path = os.path.join(output_directory, f'{mask_filename.replace("binary_", "")}')
            cv2.imwrite(output_path, rgba_image)

        else:
            print(f"Error: No contours found in the mask '{mask_path}'")
