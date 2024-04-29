//
//  water_level_repository.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/23/24.
//

import Foundation

protocol WaterLevelRepository {
    func getWaterLevels() async throws -> [WaterLevelReport]
    
    func getHistoricalData(
        stationCode: String,
        span: ObservationSpan
    ) async throws -> [HistoricalDataPoint]
}

/// #ObservationSpan
/// Span of time over which the reports should cover
enum ObservationSpan {
    
    /// Only the most recent data available
    case latest
    
    /// Results spanning one day
    case oneDay
    
    /// Reports spanning the last seven days
    case sevenDays
    
    /// Reports spanning the last thirty days
    case thirtyDays
}
