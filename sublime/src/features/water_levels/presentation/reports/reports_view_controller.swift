//
//  reports_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import UIKit
import cleanboot_swift

class ReportsViewController: UITableViewController, BaseViewController {
    var controller: ReportsController?
    
    init(
        controller: ReportsController,
        style: UITableView.Style
    ) {
        self.controller = controller
        super.init(style: style)
        sharedInit(controller)
    }
    
    required init?(coder: NSCoder) {
        do {
            super.init(coder: coder)
            let controller = ReportsController(
                viewModel: ReportsViewModel(
                    getFavoriteStatus: try AppServiceLocator.shared.get(
                        serviceType: GetFavoriteStatusUseCase.self
                    ),
                    getHistoricalData: try AppServiceLocator.shared.get(serviceType: GetHistoricalDataUseCase.self),
                    toggleFavorite: try AppServiceLocator.shared.get(serviceType: ToggleFavoriteStationUseCase.self)
                ),
                toggleFavorite: try AppServiceLocator.shared.get(
                    serviceType: ToggleFavoriteStationUseCase.self
                )
            )
            self.controller = controller
            sharedInit(self.controller!)
        } catch {
            debugPrint(error)
        }
    }
    
    func sharedInit(_ controller: ReportsController) {
        controller.viewModel.onModelReady = onModelReady(viewModel:)
        controller.viewModel.onModelUpdate = onModelUpdate(viewModel:)
        
        tableView.dataSource = controller
        tableView.delegate = controller
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
        
        tableView?.refreshControl = refreshControl
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "reportCell"
        )
        
        Task.init {
            await controller.viewModel.prepareData()
        }
    }
    
    @objc func beginRefresh() {
        Task.init {
            await controller?.beginRefresh()
        }
    }
    
    // base view controller conformance
    typealias T = ReportsViewModel
    
    func onModelUpdate(viewModel: T) {
        refreshControl?.endRefreshing()
        tableView?.reloadData()
    }
    
    func onModelReady(viewModel: T) {
        refreshControl?.endRefreshing()
        tableView?.reloadData()
    }
}
