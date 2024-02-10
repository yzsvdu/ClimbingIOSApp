//
//  HoldVisual.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 2/9/24.
//

import Foundation
import UIKit

struct HoldVisual {
    let hold: Hold
    let image: UIImage
    let width: CGFloat
    let height: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    
    init(hold: Hold, image: UIImage, width: CGFloat, height: CGFloat, xOffset: CGFloat, yOffset: CGFloat) {
        self.hold = hold
        self.image = image
        self.width = width
        self.height = height
        self.xOffset = xOffset
        self.yOffset = yOffset
    }
}
