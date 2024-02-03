//
//  PannableImageView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI


struct PannableImageView: View {
    @State private var proccessedImage: Bool = false

    // added by Ryan
    // having a local variable to store predictedHolds.routes
    @State private var allRockDivs: [String: [Int]] = [:]
    
    @Binding var routeHolds: [Int] // this was created in SelectRouteView
    @Binding var startHolds: [Int] // this was created in SelectStartHoldView
    let allowSelectStartHolds: Bool
    let image: UIImage
    let showMasks: Bool
    let showOverlay: Bool
    let predictedHolds: PredictedHolds
    let predictedMasks: Masks
    
    
    
    let startKey: String = "0"
    

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ZStack {
                Image(uiImage: image)
                if showOverlay {
                    Rectangle()
                        .foregroundColor(Color.black.opacity(0.84))
                        .frame(width: image.size.width, height: image.size.height)
                }
                if showMasks {
                    displayMasks(masks: predictedMasks.masks)
                }
                if showOverlay {
                    displayBoundingBoxes(instances: predictedHolds.instances)
                }
            }
            
            
        }
        .padding(.top, 1)
        .preferredColorScheme(ColorScheme.dark)
        .onAppear {
            
     
       
            if !allowSelectStartHolds {
                // reset routeHolds
                routeHolds.removeAll()
                print("routeHolds initial: \(routeHolds)")
                print("start holds initials: \(startHolds)")
                // copy over the original route divs into allRockDivs
                allRockDivs = predictedHolds.routes
                // fill out the first couple holds given start hold
                for sh in startHolds {
                    for(_, holdIds) in allRockDivs {
                        if holdIds.contains(sh) {
                            for hold in holdIds {
                                if !routeHolds.contains(hold) {
                                    routeHolds.append(hold)
                                }
                            }
                        }
                    }
                }
                print("routeHolds after onAppear: \(routeHolds)")
            }
        }
    }
    
    
    func displayMasks(masks: [Mask]) -> some View {
        ForEach(masks, id: \.id) { mask in
            Image(uiImage: overlayImage(image: image, mask: mask.image))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(
                    startHolds.contains(mask.id) || routeHolds.contains(mask.id) ? 1 : 0.6
                )
        }
    }
    
    func displayBoundingBoxes(instances: [InstanceData]) -> some View {
        ForEach(instances) { instance in
            let width = CGFloat(instance.box.xMax - instance.box.xMin)
            let height = CGFloat(instance.box.yMax - instance.box.yMin)
            
            let xOffset = -CGFloat(image.size.width / 2 + width / 2)
            let yOffset = -CGFloat(image.size.height / 2 + height / 2)
            
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    if allowSelectStartHolds {
                        // the user is selecting start holds not routes
                        // checks if the user clicked the same start hold
                        if let index = startHolds.firstIndex(of: instance.maskId) {
                            startHolds.remove(at: index)
                        } else {
                            // check if the user clicked on a 3rd start hold
                            if startHolds.count == 2 {
                                startHolds.removeFirst()
                            }
                            // add this start hold to the startHolds array
                            startHolds.append(instance.maskId)
                        }
                        // print out the updated start holds
                        print("current start holds: ")
                        print(startHolds)
                    } else {
                        // the user is selecting routes not start holdes
                        // make sure the user did not click the start hold
                        if !startHolds.contains(instance.maskId) {
                            // check if this hold is already in the routeHolds
                            if routeHolds.contains(instance.maskId) {
                                // the user wants to remove this hold from the routeHolds
                                // should remove from the allRockDivs
                                routeHolds.removeAll{ $0 == instance.maskId }
                                for(loc, holdIds) in allRockDivs {
                                    if holdIds.contains(instance.maskId) {
                                        if var hids = allRockDivs[loc] {
                                            hids.removeAll{ $0 == instance.maskId }
                                            allRockDivs[loc] = hids
                                        }
                                        
                                    }
                                }
                                print("current routeHolds: \(routeHolds)")
                            } else {
                                // this hold (and its neighbors) should be added to the routeHolds
                                routeSelection(maskId: instance.maskId)
                                // TODO: delete later!
                                print("current routeHolds: \(routeHolds)")
                            }
                        }

                    }
                    
                }
                .frame(
                    width: width,
                    height: height
                )
                .offset(
                    x: instance.box.xMax + xOffset,
                    y: instance.box.yMax + yOffset
                )
        }
    }
    
    /*
     allows the user to select routes and automatically fills in
     the next couple holds
     */
    func routeSelection(maskId: Int) {
        // logic: if the user presses on a hold that is already lit, unhighlight that hold AND remove it from the allRockDivs
        // need to work on sending the data to PannableImageView
       
        // iterate the PredictedHolds routes
        for(_, holdIds) in predictedHolds.routes {
            // check if the selected holds fits in the rock specific rock division
            if holdIds.contains(maskId) {
                print("rock: \(maskId) FOUND with neighbors: \(holdIds)")
                // add this hold and all its neighbors to the routeHolds!
                for hold in holdIds {
                    if !routeHolds.contains(hold) {
                        routeHolds.append(hold)
                    }
                }
            }
        }
    }
    
    func overlayImage(image: UIImage, mask: UIImage) -> UIImage {
        guard let imageReference = image.cgImage, let maskReference = mask.cgImage else {
            return image
        }

        let width = maskReference.width
        let height = maskReference.height

        // Create a bitmap context to draw the result
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }

        // Apply the mask
        context.clip(to: CGRect(x: 0, y: 0, width: width, height: height), mask: maskReference)

        // Draw the reference image within the masked area
        context.draw(imageReference, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Create a new CGImage from the context
        guard let newCGImage = context.makeImage() else {
            return image
        }

        // Create a UIImage from the new CGImage
        return UIImage(cgImage: newCGImage)
    }
}




//struct PannableImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        let dummyImage = UIImage(imageLiteralResourceName: "original_image")
//        let maskImage = UIImage(imageLiteralResourceName: "binary_mask_0")
//        let maskImage1 = UIImage(imageLiteralResourceName: "binary_mask_1")
//        let boundingBox1 = BoundingBox(xMin: 124.63375091552734, yMin: 68.79485321044922, xMax: 193.54209899902344, yMax: 152.90591430664062)
//        let boundingBox2 = BoundingBox(xMin: 276.62255859375, yMin: 88.37931823730469, xMax: 341.577880859375, yMax: 148.417236328125)
//        let instanceData1 = InstanceData(box: boundingBox1, maskId: 0)
//        let instanceData2 = InstanceData(box: boundingBox2, maskId: 1)
//        let dummyPredictedHolds = PredictedHolds(instances: [instanceData1, instanceData2], folder_path: "")
//
//        return PannableImageView(image: dummyImage, showMasks: true, showOverlay: true, predictedHolds: dummyPredictedHolds, predictedMasks: Masks(masks: [maskImage, maskImage1]))
//    }
//}
