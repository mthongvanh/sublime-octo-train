//
//  historical_data_point.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import Foundation

struct HistoricalDataPoint: Codable, Identifiable {
    var id = UUID()
    
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
    
    var date: Date {
        get {
            return Calendar.current.date(
                from: components()
            ) ?? Date()
        }
    }
    
    func components() -> DateComponents {
        let dateTime = recordDate.components(separatedBy: .whitespaces)
        
        let date = dateTime.first?.components(separatedBy: .punctuationCharacters)
        let year = Int(date![2])
        let day = Int(date![0])
        let month = Int(date![1])
        
        let time = dateTime.last?.components(separatedBy: ":")
        let hour = Int(time![0])
        let minute = Int(time![1])
        
        return DateComponents(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute
            )
    }
}
