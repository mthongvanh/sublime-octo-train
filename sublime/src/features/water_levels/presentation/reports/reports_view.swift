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
            redactedViews.task {
                await reportsData.reloadData()
            }
        case .loading:
            redactedViews
        case .loaded:
            NavigationStack {
                VStack {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(reportsData.displayedData) { s in
                                let section: ReportSection = s
                                Section(header: Text(section.title)) {
                                    ForEach(section.data) { r in
                                        let report: WaterLevelReport = r
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("\(report.waterbody) @ \(report.station)")
                                                Text("Speed: \(report.speed, specifier: "%.2f") m^3/s - Depth: \(report.depth, specifier: "%.0f") cm").font(.footnote)
                                                
                                                Text("Flow: \(report.getFlow())").font(.footnote).foregroundStyle(Color(colorForFlow(flow: report.getFlow())))
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
                        .refreshable(action: {
                            Task {
                                await reportsData.reloadData()
                            }
                        })
                        .onChange(of: reportsData.scrollTarget) { oldValue, newValue in
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .top)
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
    
    func colorForFlow(flow: WaterFlowLevel) -> UIColor {
        switch flow {
        case .low: UIColor.systemGreen
        case .high: UIColor.systemRed
        default:
            UIColor.systemYellow
        }
    }
    
    func favoriteLabel(stationCode: String) -> some View {
        let favorited: Bool = reportsData.favoriteCodes.contains(stationCode)
        let systemName: String = favorited ? "star.fill" : "star"
        let color: Color = favorited ? .yellow : .gray
        return Image.init(systemName: systemName).foregroundColor(color)
    }
    
    var redactedViews: some View {
        List {
            VStack {
                Text("Loading...").font(.headline).redacted(reason: .placeholder)
                Text("Loading...").font(.subheadline).redacted(reason: .placeholder)
            }
            VStack {
                Text("Loading...").font(.headline).redacted(reason: .placeholder)
                Text("Loading...").font(.subheadline).redacted(reason: .placeholder)
            }
            VStack {
                Text("Loading...").font(.headline).redacted(reason: .placeholder)
                Text("Loading...").font(.subheadline).redacted(reason: .placeholder)
            }
        }
    }
    
    mutating func scrollToStation(stationCode: String) {
        let report = reportsData.getReport(stationCode: stationCode)
        if let report {
            reportsData.scrollTarget = report.id
        }
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
