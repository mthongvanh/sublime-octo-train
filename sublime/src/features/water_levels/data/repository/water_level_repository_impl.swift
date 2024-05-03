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
    
    func getWaterLevels() async throws -> [WaterLevelReport] {
        return try await remoteDataSource.getWaterLevels().map<WaterLevelReport> { model in
            model.toEntity()
        }
    }
    
    func getHistoricalData(stationCode: String, span: ObservationSpan) async throws -> [HistoricalDataPoint] {
        return try await remoteDataSource.getHistoricalData(
            stationCode: stationCode,
            span: span
        ).map<HistoricalDataPoint> { model in
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
    
    private var stationCodeReplacementVariable = "$STATION_CODE"
    private var spanReplacementVariable = "$SPAN_IN_DAYS"
    
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
    
    func span(stationCode: String, days: Int = 1) -> URL {
        let url = URL(
            string: WaterLevelEndpoints.span.rawValue.replacingOccurrences(
                of: stationCodeReplacementVariable,
                with: stationCode
            ).replacingOccurrences(
                of: spanReplacementVariable,
                with: "\(days)"
            ),
            relativeTo: URL(string: baseURL)
        )!
        return url
    }
}

enum WaterLevelEndpoints: String {
    case latest = "/xml/vode/hidro_podatki_zadnji.xml"
    case span = "/vode/podatki/amp/H$STATION_CODE_t_$SPAN_IN_DAYS.html"
}
