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
            PannableImageView(image: image, showOverlay: true, predictedHolds: predicatedHolds, predictedMasks: predictedMasks)
        }.navigationTitle("Select Starting Hold")
    }
}

struct UploadImageStepView_Previews: PreviewProvider {
    static var previews: some View {
        SelectStartHoldView(image: UIImage(imageLiteralResourceName: "IMG_3502"), predicatedHolds: PredictedHolds(instances: [], folder_path: ""), predictedMasks: Masks(masks: []))
    }
}
