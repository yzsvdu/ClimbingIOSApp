//
//  ImageUploaderViewController.swift
//  ClimbingAppIOSView
//
//  Created by Vincent Duong on 1/16/24.
//

import UIKit
import Alamofire

class ImageUploaderViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePresent: Bool =  false {
        didSet {
            generateRouteButton.isEnabled = imagePresent
            instructionLabel.isHidden = imagePresent
            uploadButton.tintColor = imagePresent ? UIColor.red : UIColor.blue
            uploadButton.setTitle(imagePresent ? "Cancel" : "Upload Image", for: .normal)

        }
    }
    
    var uploadedImage: UIImage? = nil
    var defaultImage: UIImage? = nil
    
    @IBOutlet weak var routeImageView: UIView!
    @IBOutlet weak var uploadedImageView: UIImageView!
    @IBOutlet weak var generateRouteButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton! 
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultImage = uploadedImageView.image;
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(uploadImageAreaTapped(_:)))
           routeImageView.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func uploadImageAreaTapped(_ sender: UITapGestureRecognizer) {
        if !imagePresent {
            pickImage()
        }
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        if imagePresent {
            self.uploadedImage = nil
            self.uploadedImageView.image = defaultImage
            self.uploadedImageView.contentMode = .center
            self.imagePresent = false
        } else {
            self.pickImage()
        }
    }
    
    @IBAction func generateRouteButtonTapped(_ sender: UIButton) {
        if let uploadedImage = self.uploadedImage {
            uploadImage(image: uploadedImage) { poseDTO in
                self.performSegue(withIdentifier: "SelectStartHoldSegue", sender: poseDTO)
            }
        }
    }

    
        
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    // Delegate method to handle selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            dismiss(animated: true, completion: {
                self.imagePresent = true
                self.uploadedImage = image
                self.uploadedImageView.image = image
                self.uploadedImageView.contentMode = .scaleAspectFill
            })
        }
    }

    // Function to upload the selected image
    func uploadImage(image: UIImage, completion: @escaping (PoseDTO) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Error converting image to data")
            return
        }

        let endpointURL = "http://localhost:8000/api/upload_image/"

        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
        }, to: endpointURL, headers: ["X-CSRFToken": "ADD CSRF HERE IN FUTURE"])
        .responseDecodable(of: PoseDTO.self) { response in
            switch response.result {
            case .success(let poseDTO):
                completion(poseDTO)
            case .failure(let error):
                print("Error fetching Pose data: \(error.localizedDescription)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectStartHoldSegue" {
            if let destinationVC = segue.destination as? SelectHoldStepViewController {
                if let poseDTO = sender as? PoseDTO {
                    destinationVC.poseDTO = poseDTO
                }
            }
        }
    }

}
