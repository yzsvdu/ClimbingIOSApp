//
//  PredictedHolds.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//
import Foundation

struct BoundingBox: Codable {
    let xMin: Double
    let yMin: Double
    let xMax: Double
    let yMax: Double

    private enum CodingKeys: String, CodingKey {
        case xMin = "x_min"
        case yMin = "y_min"
        case xMax = "x_max"
        case yMax = "y_max"
    }
}

struct InstanceData: Codable, Identifiable {
    var id = UUID()

    let box: BoundingBox

    private enum CodingKeys: String, CodingKey {
        case box
    }
}

struct PredictedHolds: Codable {
    let instances: [InstanceData]
    let folder_path: String  
}
