//
//  reports_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import UIKit
import cleanboot_swift

class ReportsViewController: UITableViewController, BaseViewController {
    var controller: ReportsController
    
    init(
        controller: ReportsController,
        style: UITableView.Style
    ) {
        self.controller = controller
        super.init(style: style)
        sharedInit(controller)
    }
    
    required init?(coder: NSCoder) {
        self.controller = ReportsController(viewModel: ReportsViewModel())
        super.init(coder: coder)
        sharedInit(self.controller)
    }
    
    func sharedInit(_ controller: ReportsController) {
        controller.viewModel.onModelReady = onModelReady(viewModel:)
        controller.viewModel.onModelUpdate = onModelUpdate(viewModel:)
        
        tableView.dataSource = controller
        tableView.delegate = controller
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(controller, action: #selector(controller.beginRefresh), for: .valueChanged)
        
        tableView?.refreshControl = refreshControl
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "reportCell"
        )
        
        Task.init {
            await controller.viewModel.prepareData()
        }
    }
    
    // base view controller conformance
    typealias T = ReportsViewModel
    
    func onModelUpdate(viewModel: T) {
//        refreshControl?.endRefreshing()
        tableView?.reloadData()
    }
    
    func onModelReady(viewModel: T) {
//        refreshControl?.endRefreshing()
        tableView?.reloadData()
    }
}
