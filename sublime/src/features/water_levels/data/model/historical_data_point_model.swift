//
//  historical_data_point_model.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import Foundation

struct HistoricalDataPointModel: Codable {
    
    /// water measuring station code
    var stationCode: String
    
    /// date of report
    var recordDate: String
    
    /// water depth in centimeters
    var depth: Int
    
    /// water flow speed in meters per second
    var speed: Double
    
    /// water temperature in celsius
    var temperature: Double
    
    init(
        stationCode: String,
        recordDate: String,
        depth: Int,
        speed: Double,
        temperature: Double
    ) {
        self.stationCode = stationCode
        self.recordDate = recordDate
        self.depth = depth
        self.speed = speed
        self.temperature = temperature
    }
}
