//
//  station_detail_view_model.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import Foundation
import cleanboot_swift
import SwiftSoup

class StationDetailViewModel: ViewModel<StationDetailViewModel> {
    
    var stationReport: WaterLevelReport
    var getHistoricalDataUseCase: GetHistoricalDataUseCase
    
    var dataPoints = [HistoricalDataPoint]()
    var dataPointsParsed: [String:[String:[String: HistoricalDataPoint]]]?
    var chartItems = [ChartItemModel]()
    var dataType = WaterLevelValueType.depth
    var dataSpan = ObservationSpan.thirtyDays
    
    init(
        stationReport: WaterLevelReport,
        historicalData: GetHistoricalDataUseCase,
        onModelReady: OnModelReady<StationDetailViewModel>? = nil,
        onModelUpdate: OnModelUpdate<StationDetailViewModel>? = nil
    ) {
        self.stationReport = stationReport
        getHistoricalDataUseCase = historicalData
        super.init(
            onModelReady: onModelReady,
            onModelUpdate: onModelUpdate
        )
    }
    
    override func prepareData() async {
        updateLoadState(loadState: .loading)
        var hasData = false
        var result: UseCaseResult<[HistoricalDataPoint]>
        do {
            let span = ObservationSpan.thirtyDays
            
            result = try await getHistoricalDataUseCase.execute(
                params: (
                    span,
                    stationReport.stationCode
                )
            )
            switch result {
            case let .success(dataPoints):
                self.dataPoints = dataPoints
                hasData = try await filterWaterReports(
                    span: dataSpan,
                    dataType: dataType
                )
            case let .failure(error):
                throw(error)
            }
        } catch let error {
            debugPrint(error)
            updateLoadState(loadState: .error)
        }
        
        updateLoadState(loadState: hasData ? .ready : .readyNoData)
        
        if let onModelReady = onModelReady {
            DispatchQueue.main.async {
                onModelReady(self)
            }
        }
    }
    
    func filterWaterReports(span: ObservationSpan, dataType: WaterLevelValueType) async throws -> Bool {
        let dp = dataPoints.sorted(by: { a, b in
            a.date.timeIntervalSince1970 > b.date.timeIntervalSince1970
        })
        for dataPoint in dp {
            if (dataPoint.depth > 0) {
                self.dataPoints.append(dataPoint)
            } else {
                debugPrint("found empty data point \(dataPoint)")
            }
        }
        
        dataPointsParsed = organizeData(historicalData: self.dataPoints)
        let models = try generateChartItemModels(dataPointMap: dataPointsParsed!, span: span, valueType: .depth)
        chartItems.removeAll()
        chartItems.append(contentsOf: models)
        
        return !self.dataPoints.isEmpty
    }
    
    func organizeData(historicalData: [HistoricalDataPoint]) -> [String:[String:[String: HistoricalDataPoint]]] {
        /// 30-day chart will show range for a day
        /// 7-day chart will show range for a day
        ///     - chart item model will have min and max
        ///
        /// 1-day chart will not show a range, only data points
        ///     - chart itme model wil not have a min-max
        
        var monthDayTimeMap = [String:[String:[String: HistoricalDataPoint]]]()
        
        for dataPoint in historicalData {
            let dateTime = dataPoint.recordDate.components(separatedBy: .whitespaces)
            if let dateComponents = dateTime.first?.components(separatedBy: CharacterSet.punctuationCharacters) {
                let month = dateComponents[1]
                let day = dateComponents[0]
                
                // get month entries or create a new map if it doesnt exist yet
                var monthEntries = monthDayTimeMap[month] ?? [String:[String: HistoricalDataPoint]]()
                
                // get day entries or create a new map if it doesnt exist yet
                var dayEntries = monthEntries[day] ?? [String: HistoricalDataPoint]()
                // update the day entries
                dayEntries[dateTime.last!] = dataPoint
                
                // update the month entries
                monthEntries[day] = dayEntries
                
                monthDayTimeMap[month] = monthEntries
                
            }
        }
        
        return monthDayTimeMap
    }
    
    func generateChartItemModels(
        dataPointMap: [String:[String:[String:HistoricalDataPoint]]],
        span: ObservationSpan,
        valueType: WaterLevelValueType
    ) throws -> [ChartItemModel] {
        
        let addMinMax = span == ObservationSpan.sevenDays || span == ObservationSpan.thirtyDays;
        
        var models = [ChartItemModel]()
        for (month, days) in dataPointMap {
            
            for (day, times) in days {
                
                var dayMin = Double.infinity
                var dayMax = 0.0
                var year = 2024
                
                for (_, dataPoint) in times {
                    var value: Double
                    switch valueType {
                    case .depth:
                        value = Double(dataPoint.depth)
                    case .speed:
                        value = dataPoint.speed
                    case .temperature:
                        value = dataPoint.temperature
                    }
                    
                    dayMin = Swift.min(dayMin, value)
                    dayMax = Swift.max(dayMax, value)
                    year = dataPoint.components().year!
                }
                
                let components = DateComponents(
                    year: year,
                    month: Int(month),
                    day: Int(day)
                )
                
                let date = Calendar.current.date(
                    from: components
                )!
                
                var yAxisValue: Double
                let lastTimeKey = times.keys.sorted().last!
                let mostRecentReport = times[lastTimeKey]
                
                switch valueType {
                case .depth:
                    yAxisValue = Double(mostRecentReport?.depth ?? 0)
                case .speed:
                    yAxisValue = mostRecentReport?.speed ?? 0.0
                case .temperature:
                    yAxisValue = mostRecentReport?.temperature ?? 0.0
                }
                
                let model = ChartItemModel(
                    xAxisIdentifier: date,
                    yAxisValue: yAxisValue,
                    yAxisMin: addMinMax ? dayMin : nil,
                    yAxisMax: addMinMax ? dayMax : nil
                )
                
                models.append(model)
            }
            
        }
        return models
    }
}

struct ChartItemModel: Identifiable {
    var id = UUID()
    
    var xAxisIdentifier: Date
    
    var yAxisValue: Double
    var yAxisMin: Double?
    var yAxisMax: Double?
}

enum WaterLevelValueType {
    case speed
    case depth
    case temperature
}
