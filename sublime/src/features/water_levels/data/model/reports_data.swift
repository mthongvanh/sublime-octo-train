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


enum DataState {
    case initialized;
    case loaded;
    case loading;
    case error;
}


@Observable
class ReportsData {
    
    /// user-facing water body reports split by
    var displayedData = [ReportSection]()
    
    /// all favorited and non-favorited water body stations
    private var reportCollection = [WaterLevelReport]()
    
    private var waterLevelRepository: WaterLevelRepository
    
    private(set) var favoriteCodes = [String]()
    
    var dataState = DataState.initialized
    
    init(reports: [WaterLevelReport] = [WaterLevelReport](), waterLevelRepo: WaterLevelRepository) {
        reportCollection = reports
        if !reports.isEmpty {
            dataState = .loaded
        }
        waterLevelRepository = waterLevelRepo
    }
    
    @MainActor
    // @MainActor guarantees that updates happen on main thread
    func reloadData() async {
        dataState = .loading
        do {
            _reportCollection = try await waterLevelRepository.getWaterLevels()
            
            self.favoriteCodes = try waterLevelRepository.getFavorites().wrappedValue
            
            let r = sortReports(reports: _reportCollection)
            updateDisplayedData(favorites: r.favorites, others: r.other)
            dataState = .loaded
        } catch {
            debugPrint("error loading reports data \(error)")
            dataState = .error
        }
    }
    
    func loadReports(reports: [WaterLevelReport] = [WaterLevelReport]()) {
        let r = sortReports(reports: reports)
        updateDisplayedData(favorites: r.favorites, others: r.other)
    }
    
    func updateDisplayedData(favorites: [WaterLevelReport] = [WaterLevelReport](), others: [WaterLevelReport] = [WaterLevelReport]()) {
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
        var currentlyDisplayed = [WaterLevelReport]()
        displayedData.forEach { section in
            currentlyDisplayed.append(contentsOf: section.data)
        }
        
        let r = sortReports(reports: currentlyDisplayed)
        updateDisplayedData(favorites: r.favorites, others: r.other)
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
    
    func filter(query: String = "") {
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = query.trimmingCharacters(in: whitespaceCharacterSet)
        
        if strippedString.isEmpty {
            loadReports(reports: reportCollection)
            return
        }
        
        let filteredResults = reportCollection.compactMap({ report in
            if (report.waterbody.range(
                of: strippedString,
                options: [.caseInsensitive]
            )?.isEmpty == false
                || report.station.range(
                    of: strippedString,
                    options: [.caseInsensitive]
                )?.isEmpty == false)
            {
                return report
            } else {
                return nil
            }
        })
        
        loadReports(reports: filteredResults)
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
