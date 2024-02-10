//
//  UploadImageStepView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI

struct SelectStartHoldView: View {
    // added by Ryan
    @State private var selectedStartHolds: [Int] = []
    @State private var maxStartHolds: Int = 2
    @State private var canProceed : Bool = false
    
    let generatedData: GeneratedData
    let predictedMasks: [Mask]
    let holdVisuals: [HoldVisual]

    /// Tap Gesture Handler for Start Hold View
    func handleTapGesture(visual: HoldVisual) -> Void {
        if let index = selectedStartHolds.firstIndex(of: visual.hold.id) {
            selectedStartHolds.remove(at: index)
            
        } else {
            if selectedStartHolds.count == maxStartHolds {   // Adds a maximum of 2 holds in the start holds array
                selectedStartHolds.removeFirst()
            }
            selectedStartHolds.append(visual.hold.id)
            
      }
}
    
    var body: some View {
        VStack {
            PannableImageViewer(
                uploadedData: self.generatedData,       // Pass in information like original image and folder path
                holdVisuals: self.holdVisuals,          // Pass in hold visuals to display
                onTapGesture: self.handleTapGesture,    // Pass in tap gesture for select start hold instance
                selectedHolds: selectedStartHolds       // Pass in start hold array to be filled
            )
            
        }
        .navigationTitle("Select Starting Holds")
        .navigationBarItems(
            trailing: Button(action: {
                Task {
                    do {
                        try await onNextButtonPressed()
                    } catch {
                        print("Erorr: \(error)")
                    }
                }
            }) {
                Text("Next")
            }
        )
        .navigationDestination(isPresented: $canProceed) {
            SelectRouteView(
                selectedStartHolds: selectedStartHolds,         // include startholds
                generatedData: generatedData,                   // keep passing the folder name and original image
                holdVisuals: holdVisuals)                       // keep passing the hold visuals
        }
      
    }
    
    /*
     checks if there is at least one start hold and then navigates to the selectRouteView
     */
    func onNextButtonPressed() async throws {
        if(selectedStartHolds.isEmpty) {
            // TODO: have a pop up alert telling the user to select the start hold
            
        } else {
            self.canProceed = true
            
        }

    }
   
}

/* commenting this out for now

struct UploadImageStepView_Previews: PreviewProvider {
    static var previews: some View {
        SelectStartHoldView(image: UIImage(imageLiteralResourceName: "original_image"), predicatedHolds: PredictedHolds(instances: [], folder_path: "", routes: [:]), predictedMasks: Masks(masks: []))
    }
}

*/
