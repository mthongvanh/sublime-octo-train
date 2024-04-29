//
//  get_historical_data_use_case.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import Foundation
import cleanboot_swift

class GetHistoricalDataUseCase: UseCase {
    
    typealias StationCode = String
    
    typealias ResultType = [HistoricalDataPoint]
    
    typealias Parameters = (ObservationSpan?, StationCode)
    
    var repo: WaterLevelRepository
    init(repo: WaterLevelRepository) {
        self.repo = repo
    }
    
    func execute(
        params: (ObservationSpan?, StationCode)
    ) async throws -> cleanboot_swift.UseCaseResult<[HistoricalDataPoint]> {
        do {
            let reports = try await repo.getHistoricalData(
                stationCode: params.1,
                span: params.0 ?? .thirtyDays
            )
            return .success(reports)
        } catch {
            return .failure(error)
        }
    }
    
}
