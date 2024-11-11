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
    
    /// adds or removes a station to/from the favorite station collection
    ///
    /// return whether the station is a favorite or not
    func toggleStationFavorite(stationCode: String) async throws -> Bool
    
    /// Gets whether a station is a favorite or not
    ///
    /// return whether the station is a favorite or not
    func getFavoriteStatus(stationCode: String) throws -> Bool
    
    /// Gets a list of currently favorited water bodies
    ///
    /// return a collection of favorited water report station codes
    func getFavorites() throws -> [String]
}

/// #ObservationSpan
/// Span of time over which the reports should cover
enum ObservationSpan: Int, CaseIterable {
    
    /// Only the most recent data available
    case latest = 0
    
    /// Results spanning one day
    case oneDay = 1
    
    /// Reports spanning the last seven days
    case sevenDays = 7
    
    /// Reports spanning the last thirty days
    case thirtyDays = 30
}
