import UIKit
import Alamofire

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Call the image picker directly in viewDidLoad if needed
         self.pickImage()
    }

    // Function to pick an image from the photo library
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    // Delegate method to handle selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            uploadImage(image: image)
        }
    }

    // Function to upload the selected image
    func uploadImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Error converting image to data")
            return
        }

        let endpointURL = "http://localhost:8000/api/upload_image/"

        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            // Add any additional parameters if needed
            // multipartFormData.append("value".data(using: .utf8)!, withName: "key")
        }, to: endpointURL, headers: ["X-CSRFToken": "ADD CSRF HERE IN FUTURE"])
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let message = json["message"] as? String {
                    print("Response: \(message)")
                } else {
                    print("Invalid response format")
                }

            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
