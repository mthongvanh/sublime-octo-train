//
//  reports_view.swift
//  sublime
//
//  Created by Michael Thongvanh on 11/8/24.
//

import SwiftUI

struct ReportsView: View {
    
    @State private var reportsData: ReportsData
    private var onTapped: ((WaterLevelReport) -> Void)?
    
    init(reportsData: ReportsData,
         onTapped: ((WaterLevelReport) -> Void)?
    ) {
        self.reportsData = reportsData
        self.onTapped = onTapped
    }
    
    var body: some View {
        switch reportsData.dataState {
        case .initialized:
            ProgressView().task {
                await reportsData.reloadData()
            }
        case .loading:
            ProgressView()
        case .loaded:
            NavigationStack {
                VStack {
                    List {
                        ForEach(reportsData.displayedData) { s in
                            let section: ReportSection = s
                            Section(header: Text(section.title)) {
                                ForEach(section.data) { r in
                                    let report: WaterLevelReport = r
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(report.waterbody) @ \(report.station)")
                                            Text("Speed: \(report.speed, specifier: "%.2f") m/s - Depth: \(report.depth, specifier: "%.0f") cm").font(.footnote)
                                        }.frame(alignment: .topLeading)
                                        Spacer()
                                        Button(action: {
                                            Task {
                                                await reportsData.didToggleFavorite(stationCode: report.stationCode)
                                            }
                                        }) {
                                            let favorited: Bool = reportsData.favoriteCodes.contains(report.stationCode)
                                            let systemName: String = favorited ? "star.fill" : "star"
                                            let color: Color = favorited ? Color.yellow : Color.gray
                                            Image.init(systemName: systemName).foregroundColor(color)
                                        }.buttonStyle(PlainButtonStyle())
                                    }.onTapGesture {
                                        guard let onTapped else { return }
                                        onTapped(report)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        case .error:
            VStack {
                Label("Something went wrong", systemImage: "exclamationmark.triangle")
                Button {
                    Task {
                        await reportsData.reloadData()
                    }
                } label: {
                    Text("Try again")
                }
            }
        }
    }
    
    func favoriteLabel(stationCode: String) -> some View {
        let favorited: Bool = reportsData.favoriteCodes.contains(stationCode)
        let systemName: String = favorited ? "star.fill" : "star"
        let color: Color = favorited ? .yellow : .gray
        return Image.init(systemName: systemName).foregroundColor(color)
    }
}

#Preview {
    let mockWaterLevelRepo = MockWaterLevelRepo()
    let mockGetFavorites = MockGetFavorites(repo: mockWaterLevelRepo)
    let mockToggleFavorites = MockToggleFavorites(repo: mockWaterLevelRepo)
    let reports = MockReportsViewModel(
        getFavoriteStatus: mockGetFavorites,
        getHistoricalData: GetHistoricalDataUseCase(repo: mockWaterLevelRepo),
        toggleFavorite: mockToggleFavorites
    )
    let reportsData = ReportsData(reports: reports.reports, waterLevelRepo: MockWaterLevelRepo())
    ReportsView(reportsData: reportsData, onTapped: {(report) in print("tapped")})
}
