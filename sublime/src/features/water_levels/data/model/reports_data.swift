//
//  reports_data.swift
//  sublime
//
//  Created by Michael Thongvanh on 11/10/24.
//

import Foundation

struct ReportSection: Identifiable {
    var id: String {
        get {
            title
        }
    }
    
    var title: String
    var data: [WaterLevelReport]
    
    init(title: String, data: [WaterLevelReport]) {
        self.title = title
        self.data = data
    }
}

@Observable class ReportsData {
    
    /// user-facing water body reports split by
    var displayedData = [ReportSection]()
    
    /// all favorited and non-favorited water body stations
    private var reportCollection = [WaterLevelReport]()
    
    private var waterLevelRepository: WaterLevelRepository
    
    private var favoriteCodes = [String]()
    
    init(reports: [WaterLevelReport] = [WaterLevelReport](), waterLevelRepo: WaterLevelRepository) {
        reportCollection = reports
        waterLevelRepository = waterLevelRepo
    }
    
    @MainActor
    // @MainActor guarantees that updates happen on main thread
    func loadData() async {
        do {
            _reportCollection = try await waterLevelRepository.getWaterLevels()
            
            self.favoriteCodes = try waterLevelRepository.getFavorites()
            
            let r = sortReports(reports: _reportCollection)
            updateReports(favorites: r.favorites, others: r.other)
        } catch {
            debugPrint("error loading reports data \(error)")
        }
    }
    
    func updateReports(favorites: [WaterLevelReport] = [WaterLevelReport](), others: [WaterLevelReport] = [WaterLevelReport]()) {
        var reportSections = [ReportSection]()
        if (!favorites.isEmpty) {
            reportSections.append(
                ReportSection(title: "Favorite Rivers", data: favorites));
        }
        if (!others.isEmpty) {
            reportSections.append(
                ReportSection(title: "Rivers", data: others))
        }
        displayedData = reportSections
    }
    
    
    func isFavorite(stationCode: String) -> Bool {
        do {
            let favorite = try _waterLevelRepository.getFavoriteStatus(stationCode: stationCode)
            return favorite
        } catch {
            print(error)
        }
        return false
    }
    
    @MainActor
    func didToggleFavorite(stationCode: String) async {
        _ = await toggleFavorite(stationCode: stationCode)
        let r = sortReports(reports: _reportCollection)
        updateReports(favorites: r.favorites, others: r.other)
    }
    
    @MainActor
    func toggleFavorite(stationCode: String) async -> Bool {
        do {
            let fav = try await _waterLevelRepository.toggleStationFavorite(stationCode: stationCode)
            if fav {
                favoriteCodes.append(stationCode)
            } else {
                if let index = favoriteCodes.firstIndex(of: stationCode) {
                    favoriteCodes.remove(at: index)
                }
            }
            return fav
        } catch {
            debugPrint("error occurred while favoriting")
        }
        return false
    }
    
    func fetchFavoriteStatus(stationCode: String) {
        
    }
    
    func sortReports(reports: [WaterLevelReport]) -> (favorites: [WaterLevelReport], other: [WaterLevelReport]) {
        var favorite = [WaterLevelReport]()
        var nonfavorite = [WaterLevelReport]()
        for report in reports {
            if favoriteCodes.contains(report.stationCode) {
                favorite.append(report)
            } else {
                nonfavorite.append(report)
            }
        }
        
        return (favorites: favorite.sorted { $0.waterbody < $1.waterbody },
                other: nonfavorite.sorted { $0.waterbody < $1.waterbody })
    }
}
