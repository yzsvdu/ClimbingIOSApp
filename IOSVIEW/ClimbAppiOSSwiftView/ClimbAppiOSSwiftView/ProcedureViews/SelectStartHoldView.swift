//
//  UploadImageStepView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI

struct SelectStartHoldView: View {
            
    let image: UIImage
    let predicatedHolds: PredictedHolds
    let predictedMasks: Masks
    
    var body: some View {
        VStack {
            PannableImageView(image: image, showMasks: true, showOverlay: true, predictedHolds: predicatedHolds, predictedMasks: predictedMasks)
        }
        .navigationTitle("Select Starting Holds")
        .navigationBarItems(
            trailing: Button(action: {
               
            }) {
                Text("Start")
            }
        )
        
    }
}

struct UploadImageStepView_Previews: PreviewProvider {
    static var previews: some View {
        SelectStartHoldView(image: UIImage(imageLiteralResourceName: "original_image"), predicatedHolds: PredictedHolds(instances: [], folder_path: "", routes: [:]), predictedMasks: Masks(masks: []))
    }
}
