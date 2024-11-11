//
//  water_level_local_data_source.swift
//  sublime
//
//  Created by Michael Thongvanh on 5/4/24.
//

import Foundation

protocol WaterLevelLocalDataSource {
    mutating func toggleStationFavorite(
        stationCode: String
    ) async throws -> Bool
    
    func getFavoriteStatus(stationCode: String) -> Bool
    
    /// Collection of favorite water bodies
    ///
    /// Returns a list of water station codes
    func getFavorites() -> [String]
}
