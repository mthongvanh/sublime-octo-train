//
//  mocks.swift
//  sublime
//
//  Created by Michael Thongvanh on 11/11/24.
//

import Foundation
import SwiftUI

class MockReportsViewModel: ReportsViewModel {
    override var reports: [WaterLevelReport] {
        get {
            [
                WaterLevelReport(
                    waterbody: "waterBody",
                    waterType: "waterType",
                    station: "station",
                    stationCode: "stationCode",
                    latitude: 1.0,
                    longitude: 1.0,
                    dateString: "dateString",
                    speed: 1.0,
                    depth: 2.0,
                    temperature: 8.0,
                    flow: "flow"
                ),
                WaterLevelReport(
                    waterbody: "waterBody",
                    waterType: "waterType",
                    station: "station",
                    stationCode: "stationCode",
                    latitude: 1.0,
                    longitude: 1.0,
                    dateString: "dateString",
                    speed: 1.0,
                    depth: 2.0,
                    temperature: 8.0,
                    flow: "flow"
                ),
            ]
        }
        
        set {
            
        }
    }
}

class MockGetFavorites: GetFavoriteStatusUseCase {
    
}

class MockToggleFavorites: ToggleFavoriteStationUseCase {
    
}

class MockGetHistoricalData: GetHistoricalDataUseCase {
    
}

class MockWaterLevelRepo: WaterLevelRepository {
    
    func getWaterLevels() async throws -> [WaterLevelReport] {
        [
            WaterLevelReport(
                waterbody: "waterBody",
                waterType: "waterType",
                station: "station",
                stationCode: "stationCode",
                latitude: 1.0,
                longitude: 1.0,
                dateString: "dateString",
                speed: 1.0,
                depth: 2.0,
                temperature: 8.0,
                flow: "flow"
            ),
        ]
    }
    
    func getHistoricalData(stationCode: String, span: ObservationSpan) async throws -> [HistoricalDataPoint] {
        [HistoricalDataPoint]()
    }
    
    func toggleStationFavorite(stationCode: String) async throws -> Bool {
        true
    }
    
    func getFavoriteStatus(stationCode: String) throws -> Bool {
        true
    }
    
    func getFavorites() throws -> Binding<[String]> {
        Binding<[String]>(get: { ["stationCode"] }, set: { _ in
            
        })
    }
    
}

class MockStationDetailViewModel: StationDetailViewModel {
    override func fetchData(span: ObservationSpan, dataType: WaterLevelValueType) async throws -> Bool {
        var hasData = false
        let result = try await getHistoricalDataUseCase.execute(
            params: (
                span,
                stationReport.stationCode
            )
        )
        switch result {
        case let .success(dataPoints):
            self.dataPoints = dataPoints
            hasData = try await filterWaterReports(
                stationData: dataPoints,
                span: dataSpan,
                dataType: dataType
            )
        case let .failure(error):
            throw(error)
        }
        return hasData
    }

}
