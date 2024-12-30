//
//  home_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import UIKit
import MapKit
import cleanboot_swift
import SwiftUI

class HomeViewController: UIViewController, BaseViewController {
    
    var viewModel: HomeViewModel
    
    var stationMapViewController: StationMapViewController
    var stationMapController: StationMapController
    
    var reportsData: ReportsData
    
    var reportsHost: UIHostingController<ReportsView>?
    var reportsContainer: UIView = UIView()
    var reportsView: ReportsView?
    
    var filterSearchBar = UISearchBar()
    
    init(viewModel: HomeViewModel) {
        // setup view model
        self.viewModel = viewModel
        
        do {
            let smvm = StationMapViewModel(onModelReady: nil, onModelUpdate: nil)
            stationMapController = StationMapController(viewModel: smvm, didSelectAnnotation: nil)
            stationMapViewController = StationMapViewController(
                controller: stationMapController
            )

            reportsData = ReportsData(waterLevelRepo: try AppServiceLocator.shared.get(
                serviceType: WaterLevelRepository.self
            ))
            super.init(nibName: nil, bundle: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
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
        do {
            let getHistoricalDataUseCase = try AppServiceLocator.shared.get(serviceType: GetHistoricalDataUseCase.self)
            
            reportsView = ReportsView(reportsData: reportsData,
                                       onTapped: { report in
                self.navigateToReport(report: report, historicalData: getHistoricalDataUseCase)
            })
            
            filterSearchBar.delegate = self
            filterSearchBar.showsCancelButton = true
            
            reportsHost = setupReports()
            
            stationMapController.didSelectAnnotation = { annotation in
                self.reportsView?.scrollToStation(stationCode: annotation.stationCode)
            }
            
            // make sure to add subviews before setting up constraints
            view.addSubview(stationMapViewController.mapView)
            view.addSubview(reportsContainer)
            view.addSubview(filterSearchBar)
            
            setupConstraints()
        } catch {
            print(error)
        }
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
        
        reportsContainer.snp.makeConstraints({ make in
            make.leading.trailing.bottom.equalToSuperview()
        })
        
        reportsContainer.snp.makeConstraints { make in
            make.top.equalTo(filterSearchBar.snp.bottom)
        }    }
    
    func setupReports() -> UIHostingController<ReportsView> {
        /// cleanup old hosting controller and chart
        if (reportsHost != nil) {
            reportsHost?.removeFromParent()
            reportsHost?.view.removeFromSuperview()
            reportsHost = nil
        }
        
        let host = UIHostingController(
            rootView: reportsView!
        )
        host.sizingOptions = .intrinsicContentSize
        host.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(host)
        
        reportsContainer.addSubview(host.view)
        host.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        host.didMove(toParent: self)
        return host
    }
    
    // base view controller conformance
    typealias T = HomeViewModel
    
    func onModelUpdate(viewModel: T) {
        reportsData.loadReports(reports: viewModel.reports)
    }
    
    func onModelReady(viewModel: T) {
        stationMapViewController.controller.updateStations(reports: viewModel.reports)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reportsData.filter(query: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

/// Navigation section
extension HomeViewController {
    func navigateToReport(report: WaterLevelReport, historicalData: GetHistoricalDataUseCase) {
        self.navigationController?.pushViewController(
            UIHostingController(
                rootView: StationDetail(
                    viewModel: StationDetailViewModel(
                        stationReport: report,
                        historicalData: historicalData
                    )
                )
            ),
            animated: true)
    }
}
