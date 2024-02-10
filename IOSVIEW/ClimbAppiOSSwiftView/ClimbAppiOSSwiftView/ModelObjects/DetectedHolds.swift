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

struct Hold: Codable, Identifiable {
    let box: BoundingBox
    let id: Int

    private enum CodingKeys: String, CodingKey {
        case box
        case id = "mask_number"
    }
}

struct DetectedHolds: Codable {
    let instances: [Hold]
    let folder_path: String
    let routes: [String: [Int]]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.instances = try container.decode([Hold].self, forKey: .instances)
        self.folder_path = try container.decode(String.self, forKey: .folder_path)
        self.routes = try container.decode([String : [Int]].self, forKey: .routes)
    }
    
    init() {
        self.instances = []
        self.folder_path = ""
        self.routes = [:]
    }
}
