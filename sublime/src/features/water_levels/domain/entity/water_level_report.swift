//
//  water_level_report.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import Foundation

struct WaterLevelReport: Codable {
    var waterbody: String
    var waterType: String
    var station: String
    var latitude: Double
    var longitude: Double
    var dateString: String
    var speed: Double
    var depth: Double
    var flow: String
}

extension WaterLevelReport {
    public func getFlow() -> WaterFlowLevel {
        switch flow {
            
        case "srednji pretok":
            return .medium
            
        case "mali pretok":
            return .low
            
        case "velik pretok":
            return .high
            
        default:
            return .unknown
        }
    }
}

enum WaterFlowLevel: String {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case unknown = "unknown"
}
