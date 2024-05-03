//
//  get_water_levels_use_case.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/24/24.
//

import Foundation
import cleanboot_swift

struct GetWaterLevelsUseCase: UseCase {
    var repo: WaterLevelRepository
    init(repo: WaterLevelRepository) {
        self.repo = repo
    }
    
    func execute(params: Void) async throws -> cleanboot_swift.UseCaseResult<[WaterLevelReport]> {
        do {
            let reports = try await repo.getWaterLevels()
            return .success(reports)
        } catch {
            return .failure(error)
        }
    }
    
    typealias ResultType = [WaterLevelReport]
    
    typealias Parameters = Void
    
    
    
}
