//
//  home_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import UIKit
import MapKit
import cleanboot_swift

class HomeViewController: UIViewController, BaseViewController {
    
    var viewModel: HomeViewModel
    
    var reportsViewController: ReportsViewController
    var stationMapViewController: StationMapViewController
    
    var filterSearchBar = UISearchBar()
    var reportFilterController: ReportsController?
    var filterResultsTableView = UITableView()
    
    init(viewModel: HomeViewModel) {
        // setup view model
        self.viewModel = viewModel
        
        let rvm = ReportsViewModel()
        let rc = ReportsController(viewModel: rvm)
        reportsViewController = ReportsViewController(
            controller: rc,
            style: .plain
        )

        let smvm = StationMapViewModel(onModelReady: nil, onModelUpdate: nil)
        let smc = StationMapController(viewModel: smvm)
        stationMapViewController = StationMapViewController(
            controller: smc
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // view setup
    func setupViews() {
        
        filterSearchBar.delegate = self
        filterSearchBar.showsCancelButton = true
        
        reportsViewController.controller.onSelect = { (indexPath, report) in
            self.stationMapViewController.controller.viewModel.lastSelectedLocation = report
        }
        
        filterResultsTableView.isHidden = true
        filterResultsTableView.dataSource = reportFilterController
        filterResultsTableView.delegate = reportFilterController
        filterResultsTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "reportCell"
        )
        
        // make sure to add subviews before setting up constraints
        view.addSubview(stationMapViewController.mapView)
        view.addSubview(reportsViewController.tableView)
        view.addSubview(filterSearchBar)
        view.addSubview(filterResultsTableView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        stationMapViewController.mapView.snp.makeConstraints({ make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(
                stationMapViewController.controller.viewModel.mapHeightFactor
            )
        })
        
        filterSearchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(stationMapViewController.mapView.snp.bottom)
        }
        
        reportsViewController.tableView.snp.makeConstraints({ make in
            make.leading.trailing.bottom.equalToSuperview()
        })
        
        reportsViewController.tableView.snp.makeConstraints { make in
            make.top.equalTo(filterSearchBar.snp.bottom)
        }
        
        filterResultsTableView.snp.makeConstraints({ make in
            make.leading.trailing.bottom.equalToSuperview()
        })
        
        filterResultsTableView.snp.makeConstraints { make in
            make.top.equalTo(filterSearchBar.snp.bottom)
        }
    }
    
    // base view controller conformance
    typealias T = HomeViewModel
    
    func onModelUpdate(viewModel: T) {
        reportsViewController.tableView.reloadData()
        filterResultsTableView.reloadData()
    }
    
    func onModelReady(viewModel: T) {
        reportsViewController.controller.setReports(viewModel.reports)
        stationMapViewController.controller.updateStations(reports: viewModel.reports)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterResultsTableView.isHidden = (searchBar.text?.count ?? 0) < 3
        viewModel.filter(text: searchText)
        
        stationMapViewController.controller.updateStations(
            filterText: filterResultsTableView.isHidden ? nil : searchText,
            reports: viewModel.reports
        )
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
