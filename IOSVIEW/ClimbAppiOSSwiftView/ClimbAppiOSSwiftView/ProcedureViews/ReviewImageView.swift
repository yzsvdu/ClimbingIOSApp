//
//  ReviewImageView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI

struct ReviewImageView: View {
    
    @State private var proccessedImage: Bool = false
    @State private var retrievedMasks: [Mask] = []
    @State private var detectedHolds: DetectedHolds = DetectedHolds()
    @State private var holdVisuals: [HoldVisual] = []
    @State private var generatedData: GeneratedData = GeneratedData()
    
    let displayImage: UIImage
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ZStack {
                Image(uiImage: displayImage);
            }
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
            SelectStartHoldView(
                generatedData: self.generatedData,
                predictedMasks: self.retrievedMasks,
                holdVisuals: self.holdVisuals)
        }
        .navigationTitle("Review")
    }
    
    /// Uploads the image to the API and saves Results
    func processImage() async throws {
        guard let imageData = displayImage.jpegData(compressionQuality: 1) else {
            print("Error converting image to data")
            return
        }
        
        let detectedHolds = try await uploadImage(imageData: imageData)
        let retrievedMasks = try await retrieveAllMasks(detectedHolds: detectedHolds)
        
        self.detectedHolds = detectedHolds
        self.retrievedMasks = retrievedMasks
        
        
        // Generates cropped images of the holds from the binary masks
        var holdVisuals: [HoldVisual] = []
        
        for (mask, instance) in zip(retrievedMasks, detectedHolds.instances) {
            let holdOverlay: UIImage = overlayImage(image: displayImage, mask: mask.image)
            
            let width = CGFloat(instance.box.xMax - instance.box.xMin)
            let height = CGFloat(instance.box.yMax - instance.box.yMin)
            
            let xOffset = -CGFloat(displayImage.size.width / 2 + width / 2)
            let yOffset = -CGFloat(displayImage.size.height / 2 + height / 2)
            
            let cropRect = CGRect(x: instance.box.xMin, y: instance.box.yMin, width: width, height: height)
            
            let cgImage = holdOverlay.cgImage?.cropping(to: cropRect)
            let croppedImage = UIImage(cgImage: cgImage!)
            
            holdVisuals.append(HoldVisual(hold: instance, image: croppedImage, width: width, height: height, xOffset: xOffset, yOffset: yOffset))
            
        }
        
        self.holdVisuals = holdVisuals
        
        // Generated Data to hold important data like folder path name
        self.generatedData = GeneratedData(image: displayImage, folderPath: detectedHolds.folder_path, holdDivisions: detectedHolds.routes)
        
        self.proccessedImage = true
    }

}

struct ReviewImageView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewImageView(displayImage: UIImage(imageLiteralResourceName: "original_image"))
    }
}
