//
//  water_level_report_model.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import Foundation

//    <reka>Mura</reka>
//    <merilno_mesto>Gornja Radgona</merilno_mesto>
//    <ime_kratko>Mura - Gor. Radgona</ime_kratko>
//    <datum>2024-04-22 22:00</datum>
//    <vodostaj>105</vodostaj>
//    <pretok>136.9</pretok>
//    <pretok_znacilni>srednji pretok</pretok_znacilni>
//    <temp_vode>9.0</temp_vode>
//    <prvi_vv_pretok>600</prvi_vv_pretok>
//    <drugi_vv_pretok>905</drugi_vv_pretok>
//    <tretji_vv_pretok>1180</tretji_vv_pretok>


struct WaterLevelReportModel: Codable {
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
