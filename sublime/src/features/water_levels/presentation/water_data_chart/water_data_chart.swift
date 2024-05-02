//
//  water_data_chart.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//
import Charts
import SwiftUI

class WaterChartData: ObservableObject {
    @Published var data: [ChartItemModel]
    var lastReport: WaterLevelReport
    var dataType: WaterLevelValueType
    
    init(data: [ChartItemModel], lastReport: WaterLevelReport, dataType: WaterLevelValueType) {
        self.data = data
        self.lastReport = lastReport
        self.dataType = dataType
    }
}

struct water_data_chart: View {
    
    @ObservedObject var dataPoints: WaterChartData
    
    init(dataPoints: WaterChartData) {
        self.dataPoints = dataPoints
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(dataPoints.lastReport.waterbody) @ \(dataPoints.lastReport.station)")
                .font(.title2.bold())
            Text(textForDataType(dataType: dataPoints.dataType))
                .foregroundStyle(.secondary)
            Chart {
                ForEach(dataPoints.data) {
                    
                    LineMark(
                        x: .value("Day", String(describing: $0.xAxisIdentifier)),
                        y: .value("Value", $0.yAxisMax!)
                    )
                    .foregroundStyle(.gray)
                    .interpolationMethod(.catmullRom)
                }
                let average = valueForDataType(dataType: dataPoints.dataType)
                RuleMark(
                    y: .value("Average", average)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .annotation(position: .bottom, alignment: .leading) {
                    Text("Current: \(average, format: .number)")
                        .font(.body.bold())
                        .foregroundStyle(.white)
                        .padding(10.0)
                        .background(.blue.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 10))
            }
            
        }
    }
    
    func textForDataType(dataType: WaterLevelValueType) -> String {
        var dataValueDescription: String
        switch dataPoints.dataType {
        case .depth:
            dataValueDescription = "Depth in cm"
        case .speed:
            dataValueDescription = "Speed in m^3/s"
        case .temperature:
            dataValueDescription = "Temperature in Celsius"
        }
        return dataValueDescription
    }
    
    func valueForDataType(dataType: WaterLevelValueType) -> Double {
        var average: Double
        switch dataPoints.dataType {
        case .depth:
            average = Double(dataPoints.lastReport.depth)
        case .speed:
            average = dataPoints.lastReport.speed
        case .temperature:
            average = dataPoints.lastReport.temperature
        }
        return average
    }
}

#Preview {
    water_data_chart(dataPoints: WaterChartData(data: [
        //        ChartItemModel(xAxisIdentifier: Date.now, yAxisValue: 1.0),
        //
        //        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 1 * (60 * 60 * 30), since: Date.now), yAxisValue: 1.0),
        //        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 2 * (60 * 60 * 30), since: Date.now), yAxisValue: 2.0),
        //        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 3 * (60 * 60 * 30), since: Date.now), yAxisValue: 3.0),
        //        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 4 * (60 * 60 * 30), since: Date.now), yAxisValue: 4.0),
        
        
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 1 * (60 * 60 * 30), since: Date.now), yAxisValue: 1.0, yAxisMin: 0.2, yAxisMax: 0.1),
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 2 * (60 * 60 * 30), since: Date.now), yAxisValue: 2.0, yAxisMin: 2.0, yAxisMax: 5.0),
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 3 * (60 * 60 * 30), since: Date.now), yAxisValue: 3.0, yAxisMin: 3.0, yAxisMax: 5.0),
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 4 * (60 * 60 * 30), since: Date.now), yAxisValue: 1.0, yAxisMin: 1.0, yAxisMax: 1.0),
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 5 * (60 * 60 * 30), since: Date.now), yAxisValue: 2.0, yAxisMin: 2.0, yAxisMax: 10.0),
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 6 * (60 * 60 * 30), since: Date.now), yAxisValue: 3.0, yAxisMin: 3.0, yAxisMax: 3.0),
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 7 * (60 * 60 * 30), since: Date.now), yAxisValue: 1.0, yAxisMin: 1.0, yAxisMax: 1.0),
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 8 * (60 * 60 * 30), since: Date.now), yAxisValue: 2.0, yAxisMin: 2.0, yAxisMax: 2.0),
        //        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 9 * (60 * 60 * 30), since: Date.now), yAxisValue: 3.0, yAxisMin: 3.0, yAxisMax: 3.0),
        //        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 10 * (60 * 60 * 30), since: Date.now), yAxisValue: 1.0, yAxisMin: 1.0, yAxisMax: 1.0),
        //        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 11 * (60 * 60 * 30), since: Date.now), yAxisValue: 2.0, yAxisMin: 2.0, yAxisMax: 2.0),
        //        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 13 * (60 * 60 * 30), since: Date.now), yAxisValue: 3.0, yAxisMin: 3.0, yAxisMax: 3.0),
        ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 13 * (60 * 60 * 30), since: Date.now), yAxisValue: 4.0, yAxisMin: 4.0, yAxisMax: 4.0)
        
    ], lastReport: WaterLevelReport(waterbody: "baca", waterType: "river", station: "baca station", stationCode: "1234", latitude: 234.234234, longitude: 342.24143, dateString: "24.4.2024", speed: 2.3, depth: 95, temperature: 5.5, flow: "rising"), dataType: WaterLevelValueType.depth))
}
