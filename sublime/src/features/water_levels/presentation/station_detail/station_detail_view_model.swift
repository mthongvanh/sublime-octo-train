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
    //    var dataPointsParsed: [String:[String:[String: HistoricalDataPoint]]]?
    var chartItems = [ChartItemModel]()
    var dataType = WaterLevelValueType.depth
    var dataSpan = ObservationSpan.sevenDays
    
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
        do {
            hasData = try await fetchData(
                span: dataSpan,
                dataType: dataType
            )
        } catch let error {
            debugPrint(error)
            loadState = .error
        }
        
        loadState = hasData ? .ready : .readyNoData
        
        if let onModelReady = onModelReady {
            DispatchQueue.main.async {
                onModelReady(self)
            }
        }
    }
    
    func fetchData(span: ObservationSpan, dataType: WaterLevelValueType) async throws -> Bool {
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
    
    func filterWaterReports(stationData: [HistoricalDataPoint]? = nil, span: ObservationSpan, dataType: WaterLevelValueType) async throws -> Bool {
        
        dataSpan = span
        self.dataType = dataType
        
        let dp = (stationData ?? dataPoints).sorted(by: { a, b in
            a.date.timeIntervalSince1970 > b.date.timeIntervalSince1970
        })
        
        var updatedDataPoints = [HistoricalDataPoint]()
        for dataPoint in dp {
            if (dataPoint.depth == 0 && dataPoint.speed == 0 && dataPoint.temperature == 0) {
                debugPrint("found empty data point \(dataPoint)")
            } else {
                updatedDataPoints.append(dataPoint)
            }
        }
        
        //        self.dataPoints = updatedDataPoints
        
        let dataPointsParsed = organizeData(historicalData: updatedDataPoints)
        let models = try generateChartItemModels(dataPointMap: dataPointsParsed, span: span, valueType: dataType)
        chartItems.removeAll()
        chartItems.append(contentsOf: models)
        
        return !updatedDataPoints.isEmpty
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
    
    fileprivate func addChartItemModel(
        _ year: Int,
        _ month: String,
        _ day: String,
        _ valueType: WaterLevelValueType,
        _ yAxisValue: Double,
        _ models: inout [ChartItemModel],
        hour: Int? = nil,
        minute: Int? = nil,
        dayMax: Double? = nil
    ) {
        let components = DateComponents(
            year: year,
            month: Int(month),
            day: Int(day),
            hour: hour,
            minute: minute
        )
        
        let date = Calendar.current.date(
            from: components
        )!
        
        let model = ChartItemModel(
            xAxisIdentifier: date,
            yAxisValue: yAxisValue,
            yAxisMax: dayMax ?? yAxisValue
        )
        
        models.append(model)
    }
    
    func generateChartItemModels(
        dataPointMap: [String:[String:[String:HistoricalDataPoint]]],
        span: ObservationSpan,
        valueType: WaterLevelValueType
    ) throws -> [ChartItemModel] {
        
        var models = [ChartItemModel]()
        let sortedMonthKeys = dataPointMap.keys.sorted()
        try sortedMonthKeys.indices.forEach<Array<Dictionary<String, [String : [String : HistoricalDataPoint]]>.Keys.Element>> { index in
            let monthKey = sortedMonthKeys[index]
            guard let days = dataPointMap[monthKey] else {
                return
            }
            
            let sortedDayKeys = days.keys.sorted()
            try sortedDayKeys.indices.forEach<Array<Dictionary<String, [String : HistoricalDataPoint]>.Keys.Element>> { index in
                let dayKey = sortedDayKeys[index]
                guard let times = days[dayKey] else {
                    return
                }
                
                var dayMin = Double.infinity
                var dayMax = 0.0
                var year = 2024
                
                /// either generate chart items for each data point in a day for single-day spans, or generate
                /// them using the day's minimum and maximum values
                let sortedTimeKeys = times.keys.sorted()
                try sortedTimeKeys.indices.forEach<Array<Dictionary<String, HistoricalDataPoint>.Keys.Element>> { index in
                    let timeKey = sortedTimeKeys[index]
                    guard let dataPoint = times[timeKey] else {
                        return
                    }
                    
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
                    
                    /// since the span is only one day, we need several chart items to create a chart
                    if span == .oneDay {
                        let hourMinute = timeKey.components(separatedBy: .punctuationCharacters)
                        addChartItemModel(
                            year,
                            monthKey,
                            dayKey,
                            valueType,
                            value,
                            &models,
                            hour: hourMinute.first != nil ? Int(hourMinute.first!) : nil,
                            minute: hourMinute.last != nil ? Int(hourMinute.last!) : nil
                        )
                    }
                }
                
                /// since the span covers several days, we only take the day's min and max values for less
                /// noisy charts
                if span == .sevenDays || span == .thirtyDays {
                    
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
                    
                    addChartItemModel(
                        year,
                        monthKey,
                        dayKey,
                        valueType,
                        yAxisValue,
                        &models,
                        dayMax: dayMax
                    )
                }
            }
            
        }
        return models
    }
    
    func availableSpanLengths() -> [ObservationSpan] {
        return ObservationSpan.allCases.compactMap { span in
            if span != .latest {
                return span
            } else {
                return nil
            }
        }
    }
}

struct ChartItemModel: Identifiable {
    var id = UUID()
    
    var xAxisIdentifier: Date
    
    var yAxisValue: Double
    //    var yAxisMin: Double?
    var yAxisMax: Double?
}

enum WaterLevelValueType: String, CaseIterable {
    case depth = "Depth"
    case speed = "Speed"
    case temperature = "Temperature"
}
