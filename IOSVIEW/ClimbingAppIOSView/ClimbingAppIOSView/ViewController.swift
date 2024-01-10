import UIKit
import Alamofire

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Call the image picker directly in viewDidLoad if needed
         self.pickImage()
//        self.fetchPoseData()
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
        .responseDecodable(of: PoseDTO.self) { response in
            switch response.result {
            case .success(let poseDTO):
                print("Pose Data:")
                
                for (key, value) in poseDTO.attributes {
                    print("\(key): \(value)")
                }
            case .failure(let error):
                print("Error fetching Pose data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchPoseData() {
        let url = "http://localhost:8000/api/zero_pose"

        AF.request(url).responseDecodable(of: PoseDTO.self) { response in
            switch response.result {
            case .success(let poseDTO):
                print("Pose Data:")
                for (key, value) in poseDTO.attributes {
                    print("\(key): \(value)")
                }
            case .failure(let error):
                print("Error fetching Pose data: \(error.localizedDescription)")
            }
        }
    }
    
}
