//
//  SelectRouteView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Ryan Phung on 2/1/24.
//

import SwiftUI
import Alamofire

struct SelectRouteView: View {
    // SelectRouteView is the parent and is incharge of creating routeHolds array
    @State private var routeHolds: [Int] = []
//    @Binding var routeHolds: [Int]
    @Binding var startHolds: [Int]
    let image: UIImage
    let predicatedHolds: PredictedHolds
    let predictedMasks: Masks
    
    var body: some View {
        VStack {
            PannableImageView(routeHolds: $routeHolds, startHolds: $startHolds, allowSelectStartHolds: false, image: image, showMasks: true, showOverlay: true, predictedHolds: predicatedHolds, predictedMasks: predictedMasks)
        }
        .navigationTitle("Select Route Holds")
        .navigationBarItems(
            trailing: Button(action: {
                Task {
                    do {
                        try await uploadRoute(routeHolds: routeHolds)
                    } catch {
                        print("Erorr: \(error)")
                    }
                }
            }) {
                Text("Done")
            }
        )
        
        
    }
    
    func uploadRoute(routeHolds: [Int]) async throws {
        // specify the endpoint
        let uploadEndpoint = "http://localhost:8000/api/upload_route/"
        // convert routeHolds to JSON data
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(routeHolds) else {
            throw EncodingError.invalidValue(routeHolds, EncodingError.Context(codingPath: [], debugDescription: "Failed to encode routeHolds"))
        }
        // make the alamofire request
     
        let response = AF.upload(
            multipartFormData: { multipartFormData in
                // Append the JSON data with the name 'routeHolds'
                multipartFormData.append(Data(jsonData), withName: "routeHolds",  mimeType: "application/json")
            },
            to: uploadEndpoint,
            method: .post,
            headers: ["Content-Type": "multipart/form-data"]
            ).responseDecodable(of: Dictionary<String, String>.self) { (response) in
            // Handle the result in the completion handler
            switch response.result {
                case .success(let jsonResponse):
                    print("Received response:", jsonResponse)
                    // Perform additional actions based on the response if needed
                case .failure(let error):
                    // Handle errors from the Alamofire request
                    print("Error uploading route:", error)
                }
            }

    
        
    }
}

/*
 #Preview {
 SelectRouteView()
 }
 */
