//
//  reports_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import UIKit
import cleanboot_swift

class ReportsController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    typealias OnSelect = (IndexPath, WaterLevelReport) -> Void
    
    var viewModel: ReportsViewModel
    var onSelect: OnSelect?
    
    init(viewModel: ReportsViewModel, onSelect: OnSelect? = nil) {
        self.viewModel = viewModel
        self.onSelect = onSelect
    }
    
    func setReports(_ reports: [WaterLevelReport]) {
        self.viewModel.reports = reports
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reportCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "reportCell",
            for: indexPath
        )
        
        let viewModel = viewModel.reportCellViewModels[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = viewModel.text()
        content.secondaryText = viewModel.secondaryText()
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onSelect = onSelect {
            onSelect(indexPath, viewModel.reports[indexPath.row])
        }
    }
    
    @objc func beginRefresh() async {
        await viewModel.prepareData()
    }
}
