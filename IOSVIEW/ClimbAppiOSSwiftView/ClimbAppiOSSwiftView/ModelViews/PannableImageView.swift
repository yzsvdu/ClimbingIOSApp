//
//  PannableImageView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI


struct PannableImageView: View {
    @State private var proccessedImage: Bool = false
    @State private var startHolds: [Int] = []
    
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
    }
    
    func displayMasks(masks: [Mask]) -> some View {
        ForEach(masks, id: \.id) { mask in
            Image(uiImage: overlayImage(image: image, mask: mask.image))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(startHolds.contains(mask.id) ? 1 : 0.6)
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
                    if let index = startHolds.firstIndex(of: instance.maskId) {
                        startHolds.remove(at: index)
                    } else {
                        if startHolds.count == 2 {
                            startHolds.removeFirst()
                        }
                        startHolds.append(instance.maskId)
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
