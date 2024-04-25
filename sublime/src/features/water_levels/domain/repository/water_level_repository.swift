//
//  water_level_repository.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/23/24.
//

import Foundation

protocol WaterLevelRepository {
    func getWaterLevels(span: ObservationSpan) async throws -> [WaterLevelReport]
}

/// #ObservationSpan
/// Span of time over which the reports should cover
enum ObservationSpan {
    
    /// Only the most recent data available
    case latest
    
    /// Results spanning one day
    case oneDay
    
    /// Reports spanning the last sevent days
    case sevenDays
    
    /// Reports spanning the last thirty days
    case thirtyDays
}
