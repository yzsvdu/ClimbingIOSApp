//
//  ReviewImageView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI
import Alamofire

struct ReviewImageView: View {

    @State private var proccessedImage: Bool = false
    @State private var predictedHolds: PredictedHolds = PredictedHolds(instances: [], folder_path: "")
    @State private var predictedMasks: Masks = Masks(masks: [])

    let image: UIImage
    
    
    
    func uploadImage(imageData: Data) async throws -> PredictedHolds {
        let uploadEndpoint = "http://localhost:8000/api/upload_image/"

        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            }, to: uploadEndpoint, headers: ["X-CSRFToken": "ADD_CSRF_HERE_IN_FUTURE"])
            .responseDecodable(of: PredictedHolds.self) { response in
                switch response.result {
                case .success(let predictedHolds):
                    continuation.resume(returning: predictedHolds)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func retrieveMaskUrls(folder_path: String) async throws -> MaskURLs {
        let maskUrlsEndpoint = "http://localhost:8000/api/get_masks_urls/?folder_path=\(folder_path)"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(maskUrlsEndpoint)
                .responseDecodable(of: MaskURLs.self) { response in
                    switch response.result {
                    case .success(let maskUrls):
                        continuation.resume(returning: maskUrls)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    
    func retrieveMaskFromUrl(folder_path: String, mask_id: Int) async throws -> UIImage {
        let maskEndpoint = "http://localhost:8000/api/get_mask/?folder_path=\(folder_path)&mask_number=\(mask_id)"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.download(maskEndpoint)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            continuation.resume(returning: image)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    
    func retrieveAllMasks(folder_path: String, maskUrls: MaskURLs) async throws -> [UIImage] {
        var retrievedMasks: [UIImage] = []

        for (index, _) in maskUrls.maskURLs.enumerated() {
            do {
                let maskImage = try await retrieveMaskFromUrl(folder_path: folder_path, mask_id: index)
                retrievedMasks.append(maskImage)
            } catch {
                print("Error retrieving mask for index \(index): \(error)")
                // Handle the error if needed
            }
        }

        return retrievedMasks
    }
    
    func processImage() async throws {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
               print("Error converting image to data")
               return
        }
        let predictedHolds = try await uploadImage(imageData: imageData)
        let maskUrls = try await retrieveMaskUrls(folder_path: predictedHolds.folder_path)
        let masks = try await retrieveAllMasks(folder_path: predictedHolds.folder_path, maskUrls: maskUrls)

        // Update the state with the processed images
        self.predictedHolds = predictedHolds
        self.predictedMasks = Masks(masks: masks)
        print(self.predictedMasks.masks.count)
        self.proccessedImage = true
    }
    
    var body: some View {
        VStack(spacing:0){
            PannableImageView(image: image, showOverlay: false, predictedHolds: nil, predictedMasks: Masks(masks: []))
        }.navigationBarItems(
            trailing: Button(action: {
                Task {
                    do {
                        try await processImage()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }) {
                Text("Process")
            }
        )
        .navigationDestination(isPresented: $proccessedImage) {
            SelectStartHoldView(image: image, predicatedHolds: self.predictedHolds, predictedMasks: self.predictedMasks)
        }
        .navigationTitle("Review")
    }
}

struct ReviewImageView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewImageView(image: UIImage(imageLiteralResourceName: "IMG_3502"))
    }
}
