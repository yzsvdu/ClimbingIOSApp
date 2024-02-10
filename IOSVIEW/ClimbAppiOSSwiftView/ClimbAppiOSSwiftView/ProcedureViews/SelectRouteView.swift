//
//  SelectRouteView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Ryan Phung on 2/1/24.
//

import SwiftUI
import Alamofire

struct SelectRouteView: View {
    @State private var selectedRouteHolds: [Int] = []
    @State private var holdDivisions: [String: [Int]] = [:]

    let selectedStartHolds: [Int]
    let generatedData: GeneratedData
    let holdVisuals: [HoldVisual]
    
    init(selectedStartHolds: [Int], generatedData: GeneratedData, holdVisuals: [HoldVisual]) {
        self.selectedStartHolds = selectedStartHolds
        self.generatedData = generatedData
        self.holdVisuals = holdVisuals
        
        
        _holdDivisions = State(initialValue: generatedData.holdDivisions)

        _selectedRouteHolds = State(initialValue: selectedStartHolds)
        
     }
    
    
    
    func handleTapGesture(visual: HoldVisual) -> Void {
        if selectedStartHolds.contains(visual.hold.id) {return}
        
        if selectedRouteHolds.contains(visual.hold.id) {

            selectedRouteHolds.removeAll{ $0 == visual.hold.id }
            for(divisionId, holdIds) in holdDivisions {
                if holdIds.contains(visual.hold.id) {
                    if var updatedHoldIds = holdDivisions[divisionId] {
                        updatedHoldIds.removeAll{ $0 == visual.hold.id}
                        holdDivisions[divisionId] = updatedHoldIds
                        holdDivisions[UUID().uuidString] = [visual.hold.id] // generate a new division to prevent losing this id
                    }

                }
            }
            
        } else {
            // add selected hold and matching holds to the route
            for(_, holdIds) in holdDivisions {
                if holdIds.contains(visual.hold.id) {
                    for holdId in holdIds {
                        if !selectedRouteHolds.contains(holdId) {
                            selectedRouteHolds.append(holdId)
                        }
                    }
                }
            }
        
        }
    }
    var body: some View {
        VStack {
            PannableImageViewer(
                uploadedData: self.generatedData,
                holdVisuals: self.holdVisuals,
                onTapGesture: self.handleTapGesture,
                selectedHolds: self.selectedRouteHolds)
        }
        .onAppear {
            // add any neighbors of the start hold to the selectedRouteHolds array
            for startHolds in selectedStartHolds {
                for(_, holdIds) in holdDivisions {
                    if holdIds.contains(startHolds) {
                        for hold in holdIds {
                            if !selectedRouteHolds.contains(hold) {
                                selectedRouteHolds.append(hold)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Route Holds")
        .navigationBarItems(
            trailing: Button(action: {
                Task {
                    do {
                        
                        try await uploadRoute(routeHolds: selectedRouteHolds)
                    } catch {
                        print("Erorr: \(error)")
                    }
                }
            }) {
                Text("Done")
            }
        )
        
        
    }
    
    
    struct RouteData: Encodable {
        let routeHolds: [Int]
        let startHolds: [Int]
        let unique_file_name: String
    }
    
    func uploadRoute(routeHolds: [Int]) async throws {
        // specify the endpoint
        let uploadEndpoint = "http://localhost:8000/api/upload_route/"
        let routeData = RouteData(routeHolds: selectedRouteHolds, startHolds: selectedStartHolds, unique_file_name: generatedData.folderPath) // data to send to API
        
        // convert routeHolds to JSON data
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(routeData) else {
            throw EncodingError.invalidValue(routeData, EncodingError.Context(codingPath: [], debugDescription: "Failed to encode routeHolds"))
        }
        
        // make the alamofire request
        AF.upload(
            multipartFormData: { multipartFormData in
                // Append the JSON data with the name 'routeHolds'
                multipartFormData.append(Data(jsonData), withName: "data", mimeType: "application/json")
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
