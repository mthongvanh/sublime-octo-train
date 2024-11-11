//
//  water_level_report.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import Foundation
import MapKit

struct WaterLevelReport: Codable, Identifiable {
    var id: String {
        get {
            "\(stationCode)\(latitude)\(longitude)\(dateString)"
        }
    }
    
    var waterbody: String
    var waterType: String
    var station: String
    var stationCode: String
    var latitude: Double
    var longitude: Double
    var dateString: String
    var speed: Double
    var depth: Double
    var temperature: Double
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
    
    public func getLocationCoordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: CLLocationDegrees(floatLiteral: latitude),
            longitude: CLLocationDegrees(floatLiteral: longitude)
        )
    }
    
    public func valueForType(type: WaterLevelValueType) -> Double {
        switch type {
        case .depth:
            return depth
        case .speed:
            return speed
        case .temperature:
            return temperature
        }
    }
}

enum WaterFlowLevel: String {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case unknown = "unknown"
}
