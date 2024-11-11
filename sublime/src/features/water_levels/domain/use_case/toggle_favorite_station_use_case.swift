//
//  toggle_favorite_station_use_case.swift
//  sublime
//
//  Created by Michael Thongvanh on 5/3/24.
//

import Foundation
import cleanboot_swift

class ToggleFavoriteStationUseCase: UseCase {
    
    typealias StationCode = String
    
    typealias ResultType = Bool
    
    typealias Parameters = StationCode
    
    var repo: WaterLevelRepository
    init(repo: WaterLevelRepository) {
        self.repo = repo
    }
    
    func execute(
        params: StationCode
    ) async throws -> cleanboot_swift.UseCaseResult<Bool> {
        do {
            let reports = try await repo.toggleStationFavorite(
                stationCode: params
            )
            return .success(reports)
        } catch {
            return .failure(error)
        }
    }
    
}

