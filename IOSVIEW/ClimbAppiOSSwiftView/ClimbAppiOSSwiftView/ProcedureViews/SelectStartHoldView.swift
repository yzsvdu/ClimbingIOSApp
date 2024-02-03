//
//  UploadImageStepView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI

struct SelectStartHoldView: View {
    // added by Ryan
    @State private var startHolds: [Int] = []
    @State private var startHoldsFilled: Bool = false
            
    let image: UIImage
    let predicatedHolds: PredictedHolds
    let predictedMasks: Masks
    
    var body: some View {
        VStack {
            PannableImageView(routeHolds: .constant([Int]()), startHolds: $startHolds, allowSelectStartHolds: true, image: image, showMasks: true, showOverlay: true, predictedHolds: predicatedHolds, predictedMasks: predictedMasks)
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
        .navigationDestination(isPresented: $startHoldsFilled) {
            SelectRouteView(startHolds: $startHolds, image: image, predicatedHolds: self.predicatedHolds, predictedMasks: self.predictedMasks)
        }
      
    }
    
    /*
     checks if there is at least one start hold and then navigates to the selectRouteView
     */
    func onNextButtonPressed() async throws {
        print("PRESSED THE NEXT BUTTON... File: \(URL(fileURLWithPath: #file).lastPathComponent), Line: \(#line)")
        print("START HOLDS: \(startHolds)")
        
        // check if the startHolds array is empty
        if(startHolds.isEmpty) {
            // user error: start holds are empty!
            print("Start holds are empty")
            // TODO: have a pop up alert telling the user to select the start hold
        } else {
            // at least one start hold is selected
            print("Ready to move on to the SelectRouteView")
            // transition to the SelectRouteView
            self.startHoldsFilled = true
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
