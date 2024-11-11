//
//  get_favorite_status_use_case.swift
//  sublime
//
//  Created by Michael Thongvanh on 5/5/24.
//

import Foundation
import cleanboot_swift

class GetFavoriteStatusUseCase: UseCase {
    
    typealias StationCode = String
    
    typealias ResultType = Bool
    
    typealias Parameters = StationCode
    
    var repo: WaterLevelRepository
    init(repo: WaterLevelRepository) {
        self.repo = repo
    }
    
    func execute(
        params: StationCode
    )  throws -> cleanboot_swift.UseCaseResult<Bool> {
        do {
            let reports = try repo.getFavoriteStatus(
                stationCode: params
            )
            return .success(reports)
        } catch {
            return .failure(error)
        }
    }
    
}

