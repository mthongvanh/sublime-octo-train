//
//  File.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import Foundation
import cleanboot_swift

class ReportsViewModel: ViewModel<ReportsViewModel> {
    
    var reportCollection = [WaterLevelReport]()
    private var _displayedReports = [WaterLevelReport]()
    
    var reportCellViewModels = [ReportCellViewModel]()
    
    init(
        reports: [WaterLevelReport] = [WaterLevelReport](),
        reportCellViewModels: [ReportCellViewModel] = [ReportCellViewModel]()
    ) {
        self.reportCollection = reports
        self.reportCellViewModels = reportCellViewModels
        
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
    
    func updateCellViewModels(_ reports: [WaterLevelReport]) {
        do {
            self.reportCellViewModels = try reports.map<ReportCellViewModel>({ report in
                ReportCellViewModel(report: report)
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
