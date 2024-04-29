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
    var filterViewController: ReportFilterViewController
    var stationMapViewController: StationMapViewController
    
    var filterSearchBar = UISearchBar()
    
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
        
        let filterVM = ReportsViewModel()
        let filterController = ReportsController(viewModel: filterVM)
        filterViewController = ReportFilterViewController(
            controller: filterController,
            style: .plain
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
            if (report.station == self.stationMapViewController.controller.viewModel.lastSelectedLocation?.station) {
                do {
                    let vm = StationDetailViewModel(
                        historicalData: try AppServiceLocator.shared.get(
                            serviceType: GetHistoricalDataUseCase.self
                        )
                    )
                    let controller = StationDetailController(viewModel: vm)
                    
                    self.navigationController?.pushViewController(
                        StationDetailViewController(
                            controller: controller
                        ),
                        animated: true
                    )
                } catch {
                    debugPrint(error)
                }
            } else {
                self.stationMapViewController.controller.viewModel.lastSelectedLocation = report
            }
        }
        
        filterViewController.tableView.isHidden = true
        
        // make sure to add subviews before setting up constraints
        view.addSubview(stationMapViewController.mapView)
        view.addSubview(reportsViewController.tableView)
        view.addSubview(filterSearchBar)
        view.addSubview(filterViewController.tableView)
        
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
        
        filterViewController.tableView.snp.makeConstraints({ make in
            make.leading.trailing.bottom.equalToSuperview()
        })
        
        filterViewController.tableView.snp.makeConstraints { make in
            make.top.equalTo(filterSearchBar.snp.bottom)
        }
    }
    
    // base view controller conformance
    typealias T = HomeViewModel
    
    func onModelUpdate(viewModel: T) {
        reportsViewController.tableView.reloadData()
        filterViewController.tableView.reloadData()
    }
    
    func onModelReady(viewModel: T) {
        reportsViewController.controller.setReports(viewModel.reports)
        filterViewController.controller.viewModel.reportCollection = viewModel.reports
        stationMapViewController.controller.updateStations(reports: viewModel.reports)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterViewController.tableView.isHidden = (searchBar.text?.count ?? 0) < 3
        filterViewController.controller.filter(text: searchText)
        
        stationMapViewController.controller.updateStations(
            filterText: filterViewController.tableView.isHidden ? nil : searchText,
            reports: viewModel.reports
        )
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
