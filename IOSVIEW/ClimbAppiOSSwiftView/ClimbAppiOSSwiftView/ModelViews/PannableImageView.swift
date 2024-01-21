//
//  PannableImageView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI


struct PannableImageView: View {
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1
    @State private var previousScale: CGFloat = 1.0
    @State private var proccessedImage: Bool = false
    
    let image: UIImage
    let showOverlay: Bool
    let predictedHolds: PredictedHolds?
    let predictedMasks: Masks
    
    var body: some View {
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / self.previousScale
                                    self.previousScale = value
                                    self.scale *= delta
                                }
                                .onEnded { _ in
                                    self.previousScale = 1.0
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    self.offset.width += value.translation.width
                                    self.offset.height += value.translation.height
                                }
                        )
                        .overlay(
                            Group {
                                if showOverlay, let instances = predictedHolds?.instances {
                                    ForEach(instances) { instance in
                                        let width = CGFloat(instance.box.xMax - instance.box.xMin) * self.scale
                                        let height = CGFloat(instance.box.yMax - instance.box.yMin) * self.scale
                                        
                                        let xOffset = -CGFloat(image.size.width / 2 + width / 2)
                                        let yOffset = -CGFloat(image.size.height / 2 + height / 2)
                                        Rectangle()
                                            .stroke(Color.red, lineWidth: 2)
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
                                                
                            }
                        )
                    displayMasks(masks: predictedMasks.masks)
                    
                }
                
            }
            .padding(.top, 1)
            .preferredColorScheme(ColorScheme.dark)
        }
    
    func displayMasks(masks: [UIImage]) -> some View {
        ForEach(masks, id: \.self) { mask in
            Image(uiImage: overlayImage(image: image, mask: mask, color: UIColor.red))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.5)
        }
    }
    
    func overlayImage(image: UIImage, mask: UIImage, color: UIColor) -> UIImage {
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

        // Fill the masked area with the specified color
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Create a new CGImage from the context
        guard let newCGImage = context.makeImage() else {
            return image
        }

        // Create a UIImage from the new CGImage
        return UIImage(cgImage: newCGImage)
    }
}




struct PannableImageView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyImage = UIImage(imageLiteralResourceName: "original_image")
        let dummyPredictedHolds = PredictedHolds(instances: [], folder_path: "")
        return PannableImageView(image: dummyImage, showOverlay: true, predictedHolds: dummyPredictedHolds, predictedMasks: Masks(masks: []))
    }
}
