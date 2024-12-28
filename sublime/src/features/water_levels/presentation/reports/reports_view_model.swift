//
//  File.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import Foundation
import cleanboot_swift
import SwiftUI

class ReportsViewModel: ViewModel<ReportsViewModel> {
    
    var reportCollection = [WaterLevelReport]()
    private var _displayedReports = [WaterLevelReport]()
    private var _favoriteReports = [WaterLevelReport]()
    
    var reportCellViewModels = [ReportCellViewModel]()
    
    var getFavoriteStatus: GetFavoriteStatusUseCase?
    private var getHistoricalData: GetHistoricalDataUseCase
    private var toggleFavoriteUseCase: ToggleFavoriteStationUseCase
    
    init(
        reports: [WaterLevelReport] = [WaterLevelReport](),
        reportCellViewModels: [ReportCellViewModel] = [ReportCellViewModel](),
        getFavoriteStatus: GetFavoriteStatusUseCase,
        getHistoricalData: GetHistoricalDataUseCase,
        toggleFavorite: ToggleFavoriteStationUseCase
    ) {
        self.reportCollection = reports
        self.reportCellViewModels = reportCellViewModels
        self.getFavoriteStatus = getFavoriteStatus
        
        self.getHistoricalData = getHistoricalData
        self.toggleFavoriteUseCase = toggleFavorite
        
        super.init(onModelReady: nil, onModelUpdate: nil)
    }
    
    
    var reports: [WaterLevelReport] {
        get {
            _displayedReports
        }
        
        set {
            self._displayedReports = newValue
            updateCellViewModels(newValue)
            if let onModelUpdate = onModelUpdate {
                onModelUpdate(self)
            }
        }
    }
    
    var bindableReports: Binding<[WaterLevelReport]> {
        get {
            Binding<[WaterLevelReport]>(
                get: {
                    self._displayedReports
                },
                set: { reports in
                    for report in self.reportCollection {
                        if let index = self.reportCollection.firstIndex(where: { $0.id == report.id }) {
                            self.reportCollection[index] = report
                        }
                    }
                }
            )
        }
    }
    
    func updateCellViewModels(_ reports: [WaterLevelReport]) {
        do {
            self.reportCellViewModels = try reports.map<ReportCellViewModel>({ report in
                let vm = ReportCellViewModel(report: report)
                let result = try getFavoriteStatus?.execute(params: report.stationCode)
                switch result {
                case .success(let favorite):
                    vm.favorite = favorite
                default:
                    vm.favorite = false
                }
                return vm
            })
        } catch {
            debugPrint(error)
        }
    }
    
    func filter(text: String) {
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = text.trimmingCharacters(in: whitespaceCharacterSet)
        
        reports = reportCollection.compactMap({ report in
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
        
        DispatchQueue.main.async {
            guard let update = self.onModelUpdate else {
                return;
            }
            
            update(self)
        }
        
    }
}
