//
//  report_filter_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import UIKit
import cleanboot_swift

class ReportFilterViewController: ReportsViewController {
    
    override func sharedInit(_ controller: ReportsController) {
        super.sharedInit(controller)
        refreshControl = nil
        tableView.refreshControl = nil
    }
    
    typealias T = ReportsViewModel
    
    override func onModelReady(viewModel: ReportsViewModel) {
        tableView.reloadData()
    }
    
    override func onModelUpdate(viewModel: ReportsViewModel) {
        tableView.reloadData()

    }
    
}
