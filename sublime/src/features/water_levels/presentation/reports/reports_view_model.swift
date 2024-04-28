//
//  File.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import Foundation
import cleanboot_swift

class ReportsViewModel: ViewModel<ReportsViewModel> {
    
    private var _reports = [WaterLevelReport]()
    
    var reportCellViewModels = [ReportCellViewModel]()
    
    init(
        reports: [WaterLevelReport] = [WaterLevelReport](),
        reportCellViewModels: [ReportCellViewModel] = [ReportCellViewModel]()
    ) {
        self._reports = reports
        self.reportCellViewModels = reportCellViewModels
        
        super.init(onModelReady: nil, onModelUpdate: nil)
    }
    
    
    var reports: [WaterLevelReport] {
        get {
            _reports
        }
        
        set {
            self._reports = newValue
            updateCellViewModels(reports)
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
}
