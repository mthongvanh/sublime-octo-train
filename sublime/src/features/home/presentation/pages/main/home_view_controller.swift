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
import SnapKit

class HomeViewController: UIViewController, BaseViewController {
    
    var viewModel: HomeViewModel
    
    var stationMapViewController: StationMapViewController
    var stationMapController: StationMapController
    
    var reportsData: ReportsData
    
    var reportsHost: UIHostingController<ReportsView>?
    var reportsContainer: UIView = UIView()
    var reportsView: ReportsView?
    
    var mapShadowView = UIView()
    
    var filterSearchBar = UISearchBar()
    
    var mapSizeConstraint: ConstraintMakerEditable?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // view setup
    func setupViews() {
        do {
            self.view.backgroundColor = .systemGroupedBackground
            self.navigationItem.titleView = filterSearchBar

            let getHistoricalDataUseCase = try AppServiceLocator.shared.get(serviceType: GetHistoricalDataUseCase.self)
            
            reportsView = ReportsView(reportsData: reportsData,
                                       onTapped: { report in
                self.navigateToReport(report: report, historicalData: getHistoricalDataUseCase)
            })
            
            filterSearchBar.delegate = self
            filterSearchBar.showsCancelButton = true
            filterSearchBar.searchBarStyle = .minimal
            
            reportsHost = setupReports()
            
            stationMapController.didSelectAnnotation = { annotation in
                self.reportsView?.scrollToStation(stationCode: annotation.stationCode)
            }
            stationMapViewController.mapView.layer.masksToBounds = true
            stationMapViewController.mapView.layer.cornerRadius = 16

            mapShadowView.layer.masksToBounds = false
            mapShadowView.layer.cornerRadius = 16
            mapShadowView.layer.shadowColor = UIColor.black.cgColor
            mapShadowView.layer.shadowOpacity = 0.275
            mapShadowView.layer.shadowRadius = 8
            mapShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
            mapShadowView.backgroundColor = .black
            
            // make sure to add subviews before setting up constraints
            view.addSubview(mapShadowView)
            view.addSubview(stationMapViewController.mapView)
            view.addSubview(reportsContainer)
            view.addSubview(filterSearchBar)
            
            setupConstraints()
        } catch {
            print(error)
        }
    }
    
    func setupConstraints() {
        mapShadowView.snp.makeConstraints { make in
            make.edges.equalTo(stationMapViewController.mapView.snp.edges)
        }
        
        stationMapViewController.mapView.snp.makeConstraints({ make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.snp.topMargin).inset(0)
            mapSizeConstraint = make.height.equalToSuperview().multipliedBy(
                stationMapViewController.controller.viewModel.mapHeightFactor
            )
        })
        
        reportsContainer.snp.makeConstraints({ make in
            make.leading.trailing.equalToSuperview().inset(0)
            make.bottom.equalToSuperview()
        })
        
        reportsContainer.snp.makeConstraints { make in
            make.top.equalTo(stationMapViewController.mapView.snp.bottom).inset(-16)
        }
    }
    
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
        stationMapController.updateStations(filterText: searchText.count > 0 ? searchText : nil, reports: viewModel.reports)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

/// Navigation section
extension HomeViewController {
    func navigateToReport(report: WaterLevelReport, historicalData: GetHistoricalDataUseCase) {
        self.navigationController?.navigationBar.isHidden = false
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
