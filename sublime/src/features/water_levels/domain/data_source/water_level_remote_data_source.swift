//
//  water_level_remote_data_source.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/23/24.
//

import Foundation

protocol WaterLevelRemoteDataSource {
    func getWaterLevels() async throws -> [WaterLevelReportModel]
}
