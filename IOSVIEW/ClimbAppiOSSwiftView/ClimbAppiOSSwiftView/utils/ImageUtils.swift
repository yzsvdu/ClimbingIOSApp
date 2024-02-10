//
//  ImageUtils.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 2/8/24.
//

import Foundation
import UIKit

func overlayImage(image: UIImage, mask: UIImage) -> UIImage {
    guard let imageReference = image.cgImage, let maskReference = mask.cgImage else {
        return image
    }

    let width = maskReference.width
    let height = maskReference.height

    guard let context = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: width * 4,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        return image
    }

    context.clip(to: CGRect(x: 0, y: 0, width: width, height: height), mask: maskReference)

    context.draw(imageReference, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let newCGImage = context.makeImage() else {
        return image
    }
    
    return UIImage(cgImage: newCGImage)
    
}


