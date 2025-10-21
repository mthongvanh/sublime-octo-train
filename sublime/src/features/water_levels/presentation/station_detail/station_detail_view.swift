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
    let mockRepo = MockWaterLevelRepo()
    let mockGetFavorites = MockGetFavorites(repo: mockRepo)
    let mockGetHistoricalData = MockGetHistoricalData(repo: mockRepo)
    let mockToggleFavorites = MockToggleFavorites(repo: mockRepo)
    let reports = MockReportsViewModel(
        getFavoriteStatus: mockGetFavorites,
        getHistoricalData: mockGetHistoricalData,
        toggleFavorite: mockToggleFavorites
    )
    let historicalDataUseCase = GetHistoricalDataUseCase(repo: mockRepo)
    
    StationDetail(
        viewModel: StationDetailViewModel(
            stationReport: reports.reports[0],
            historicalData: historicalDataUseCase
        )
    )
}
