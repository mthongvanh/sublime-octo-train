//
//  station_detail_view.swift
//  sublime
//
//  Created by Michael Thongvanh on 12/21/24.
//

import SwiftUI
import cleanboot_swift

struct StationDetail: View {
    
    @State private var dataType: WaterLevelValueType
    @State private var dataSpan: ObservationSpan
    @State private var chartData: WaterChartData?
    @State private var chartItems = [ChartItemModel]()
    
    @State private var viewModel: StationDetailViewModel
        
    init(
        viewModel: StationDetailViewModel
    ) {
        self.viewModel = viewModel
        dataSpan = viewModel.dataSpan
        dataType = viewModel.dataType
    }
    
    var body: some View {
        switch viewModel.loadState {
        case .loading:
            ProgressView()
        case .ready:
            VStack {
                /// picker
                Picker("Time Period", selection: $dataSpan) {
                    Text("Today").tag(ObservationSpan.oneDay)
                    Text("Week").tag(ObservationSpan.sevenDays)
                    Text("Month").tag(ObservationSpan.thirtyDays)
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 16)
                .onChange(of: dataSpan) {
                    Task {
                        await updateChartData(period: dataSpan, dataType: dataType)
                    }
                }
                
                /// water data chart
                WaterDataChart(
                    dataPoints: WaterChartData(
                        data: chartItems,
                        lastReport: viewModel.stationReport,
                        dataType: dataType
                    )
                ).frame(height: 300)
                
                // create a picker with a title above it
                VStack() {
                    Text("Viewing data for the following measurement:")
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading)
                        .font(.subheadline)
                        .bold()
                    
                    Picker("Data Type", selection: $dataType) {
                        Text("Depth").tag(WaterLevelValueType.depth)
                        Text("Speed").tag(WaterLevelValueType.speed)
                        Text("Temperature").tag(WaterLevelValueType.temperature)
                    }.pickerStyle(.segmented)
                        .onChange(of: dataType) {
                            Task {
                                await updateChartData(period: viewModel.dataSpan, dataType: dataType)
                            }
                        }
                }.padding(.top)
                Spacer()
            }
            .padding(.horizontal, 16)
            .onAppear() {
                Task {
                    await updateChartData(period: viewModel.dataSpan, dataType: dataType)
                }
            }
        case .error:
            Text("Error")
        default:
            Text("Default")
        }
    }
    
    // create a function that passes the selected time period and water data type to update the chart data
    func updateChartData(period: ObservationSpan, dataType: WaterLevelValueType) async -> Void {
        do {
            var _ = try await viewModel.fetchData(span: period, dataType: dataType)
            chartItems = viewModel.chartItems
        } catch {
            print(error)
        }
    }
}


#Preview {
//    let mockGetFavorites = MockGetFavorites(repo: MockWaterLevelRepo())
//    let reports = MockReportsViewModel(getFavoriteStatus: mockGetFavorites)
//    StationDetail(viewModel: StationDetailViewModel(stationReport:reports.reports[0], historicalData: GetHistoricalDataUseCase(repo: MockWaterLevelRepo())))
    Text("preview")
}


//let mockData = WaterChartData(data: [
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 1 * (60 * 60 * 30), since: Date.now), yAxisValue: 1.0, yAxisMax: 0.1),
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 2 * (60 * 60 * 30), since: Date.now), yAxisValue: 2.0, yAxisMax: 5.0),
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 3 * (60 * 60 * 30), since: Date.now), yAxisValue: 3.0, yAxisMax: 5.0),
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 4 * (60 * 60 * 30), since: Date.now), yAxisValue: 1.0, yAxisMax: 1.0),
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 5 * (60 * 60 * 30), since: Date.now), yAxisValue: 2.0, yAxisMax: 10.0),
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 6 * (60 * 60 * 30), since: Date.now), yAxisValue: 3.0, yAxisMax: 3.0),
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 7 * (60 * 60 * 30), since: Date.now), yAxisValue: 1.0, yAxisMax: 1.0),
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 8 * (60 * 60 * 30), since: Date.now), yAxisValue: 2.0, yAxisMax: 2.0),
//    ChartItemModel(xAxisIdentifier: Date.init(timeInterval: 13 * (60 * 60 * 30), since: Date.now), yAxisValue: 4.0, yAxisMax: 4.0)
//    
//], lastReport: WaterLevelReport(waterbody: "baca", waterType: "river", station: "baca station", stationCode: "1234", latitude: 234.234234, longitude: 342.24143, dateString: "24.4.2024", speed: 2.3, depth: 95, temperature: 5.5, flow: "rising"), dataType: WaterLevelValueType.depth)
