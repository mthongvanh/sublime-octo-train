//
//  water_level_repository_impl.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/23/24.
//

import Foundation

class WaterLevelRepositoryImpl: WaterLevelRepository {
    
    private var remoteDataSource: WaterLevelRemoteDataSource
    
    init(remoteDataSource: WaterLevelRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getWaterLevels(span: ObservationSpan) async throws -> [WaterLevelReport] {
        return try await remoteDataSource.getWaterLevels().map<WaterLevelReport> { model in
            model.toEntity()
        }
    }
}

public enum Environment {
    case development
    case qa
    case stage
    case production
}

struct WaterLevelAPI {
    
    var environment: Environment
    var baseURL: String
    
    init(environment: Environment, baseURL: String) {
        self.environment = environment
        self.baseURL = baseURL
    }
    
    var latest: URL {
        get {
            let url = URL(
                string: WaterLevelEndpoints.latest.rawValue,
                relativeTo: URL(string: baseURL)
            )!
            return url
        }
    }
}

enum WaterLevelEndpoints: String {
    case latest = "/xml/vode/hidro_podatki_zadnji.xml"
}
