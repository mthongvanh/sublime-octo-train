//
//  reports_view.swift
//  sublime
//
//  Created by Michael Thongvanh on 11/8/24.
//

import SwiftUI

struct reports_view: View {
    
    private var reportsViewModel: ReportsViewModel?
    @State private var reportsData: ReportsData
    
    init(reportsViewModel: ReportsViewModel?, reportsData: ReportsData) {
        self.reportsViewModel = reportsViewModel
        self.reportsData = reportsData
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(reportsData.displayedData) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.data) { report in
                            HStack(content: {
                                VStack(alignment: .leading, content: {
                                    Text(
                                        "\(report.waterbody) @ \(report.station)")
                                    HStack(content: {
                                        Text("flow: \(report.speed) m^3/s, depth: \(report.depth) cm").font(.subheadline)
                                    })
                                })
                                Spacer()
                                Button(action: {
                                    Task {
                                        await reportsData.didToggleFavorite(stationCode:report.stationCode)
                                    }
                                }, label: {
                                    let favorite = reportsData.isFavorite(stationCode: report.stationCode)
                                    Image(
                                        systemName: favorite
                                        ? "star.fill"
                                        : "star"
                                    ).tint(favorite ? Color.yellow : Color.gray)
                                })
                            })
                        }
                    }
                }
            }
        }
        .task {
            await reportsData.loadData()
        }
    }
}

#Preview {
    let mockGetFavorites = MockGetFavorites(repo: MockWaterLevelRepo())
    let reports = MockReportsViewModel(getFavoriteStatus: mockGetFavorites)
    let reportsData = ReportsData(reports: reports.reports, waterLevelRepo: MockWaterLevelRepo())
    return reports_view(reportsViewModel: reports, reportsData: reportsData)
}
