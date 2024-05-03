//
//  water_level_report_arso.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/23/24.
//

import Foundation

struct WaterLevelReportARSO {
    // measuring station name
    var station: String //"merilno_mesto"
    
    var stationCode: String //"6060"
    
    // name composed of river name and station name
    var stationShortName: String //"ime_kratko"
    
    // latitude of measuring station
    var stationLatitude: Double
    
    // longitude of measuring station
    var stationLongitude: Double
    
    // initial high-flow reading
    var prviVvPretok: Double //"prvi_vv_pretok"
    
    // second high-flow reading
    var drugiVvPretok: Double //"drugi_vv_pretok"
    
    // third high-flow reading
    var tretjiVvPretok: Double //"tretji_vv_pretok"
    
    // temperature in celsius
    var temperature: Double //"temp_vode"
    
    // date of recorded report
    var date: String //"datum"
    
    // river name
    var river: String //"reka"
    
    // depth in centimeters
    var depth: Double //"vodostaj"
    
    // speed in cubic meters per second
    var speed: Double //"pretok"
    
    // natural-language description of flow
    var flow: String //"pretok_znacilni"
    
    init(
        station: String,
        stationCode: String,
        stationShortName: String,
        stationLatitude: Double,
        stationLongitude: Double,
        prviVvPretok: Double,
        drugiVvPretok: Double,
        tretjiVvPretok: Double,
        temperature: Double,
        date: String,
        river: String,
        depth: Double,
        speed: Double,
        flow: String
    ) {
        self.station = station
        self.stationCode = stationCode
        self.stationShortName = stationShortName
        self.stationLatitude = stationLatitude
        self.stationLongitude = stationLongitude
        self.prviVvPretok = prviVvPretok
        self.drugiVvPretok = drugiVvPretok
        self.tretjiVvPretok = tretjiVvPretok
        self.temperature = temperature
        self.date = date
        self.river = river
        self.depth = depth
        self.speed = speed
        self.flow = flow
    }
}
