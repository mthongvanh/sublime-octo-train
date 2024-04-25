//
//  home_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import UIKit
import MapKit

class HomeViewController: UIViewController, BaseViewController {
    
    var viewModel: HomeViewModel
    var tableView: UITableView?
    var mapView: MKMapView?
    
    init(viewModel: HomeViewModel) {
        // setup view model
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        // setup table view
        self.tableView = UITableView()
        self.mapView = MKMapView()
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
        // setup map view
        mapView?.delegate = self;
        mapView?.setRegion(
            viewModel.initialRegion(),
            animated: false
        )
        
        // setup reports table view
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "myCell"
        )
        
        // make sure to add subviews before setting up constraints
        view.addSubview(mapView!)
        view.addSubview(tableView!)
        
        setupConstraints()
    }

    func setupConstraints() {
        mapView?.snp.makeConstraints({ make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(
                viewModel.mapHeightFactor
            )
        })
        
        tableView?.snp.makeConstraints({ make in
            make.leading.trailing.bottom.equalToSuperview()
        })
        
        tableView?.snp.makeConstraints { make in
            make.top.equalTo(mapView!.snp.bottom)
        }
    }
    
    // base view controller conformance
    typealias T = HomeViewModel
    
    func onModelUpdate(viewModel: T) {
        tableView?.reloadData()
    }
    
    func onModelReady(viewModel: T) {
        tableView?.reloadData()
    }
}

protocol BaseViewController {
    associatedtype T
    func onModelUpdate(viewModel: T)
    func onModelReady(viewModel: T)
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        let model = viewModel.reports[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = "\(model.waterbody) @ \(model.station)"
            content.secondaryText = "flow: \(model.speed) m^3/s, depth: \(model.depth) cm"
            cell.contentConfiguration = content
        return cell
    }
}

extension HomeViewController: MKMapViewDelegate {
    
}
