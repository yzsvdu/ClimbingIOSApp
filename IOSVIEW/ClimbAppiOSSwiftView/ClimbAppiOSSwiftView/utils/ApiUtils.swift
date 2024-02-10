//
//  ApiUtils.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 2/9/24.
//

import Foundation
import Alamofire
import UIKit


/// Uploads Image to PathAPI to get detected holds
func uploadImage(imageData: Data) async throws -> DetectedHolds {
    let uploadEndpoint = "http://localhost:8000/api/upload_image/"

    return try await withCheckedThrowingContinuation { continuation in
        AF.sessionConfiguration.timeoutIntervalForRequest = 70
        AF.sessionConfiguration.timeoutIntervalForResource = 70
        
        AF.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
        }, to: uploadEndpoint, headers: ["X-CSRFToken": "ADD_CSRF_HERE_IN_FUTURE"])
        .responseDecodable(of: DetectedHolds.self) { response in
            switch response.result {
            case .success(let predictedHolds):
                continuation.resume(returning: predictedHolds)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}

/// Retrieves a binary mask file given folder name and id on the server
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

/// Wrapper function to mass retrieve binary masks
func retrieveAllMasks(detectedHolds: DetectedHolds) async throws -> [Mask] {
    var retrievedMasks: [Mask] = []

    for (index, instance) in detectedHolds.instances.enumerated() {
        do {
            let maskImage = try await retrieveMaskFromUrl(folder_path: detectedHolds.folder_path, mask_id: instance.id)
            retrievedMasks.append(Mask(id: instance.id, image: maskImage))
        } catch {
            print("Error retrieving mask for index \(index): \(error)")
        }
    }

    return retrievedMasks
}
