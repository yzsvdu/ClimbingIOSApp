//
//  UploadedData.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 2/9/24.
//

import Foundation
import UIKit

struct GeneratedData {
    let image: UIImage
    let folderPath: String
    let holdDivisions: [String: [Int]]

    
    init(image: UIImage, folderPath: String, holdDivisions: [String : [Int]]) {
        self.image = image
        self.folderPath = folderPath
        self.holdDivisions = holdDivisions
    }
    
    init() {
        self.image = UIImage()
        self.folderPath = ""
        self.holdDivisions = [:]
    }
}
