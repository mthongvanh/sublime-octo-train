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
    var tableView: UITableView?
    var refreshControl: UIRefreshControl?
    var mapView: MKMapView?

    
    var filterSearchBar = UISearchBar()
    var reportFilterController = ReportFilterController()
    var filterResultsTableView = UITableView()
    
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
        mapView?.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: "waterStationAnnoation"
        )
        
        // setup reports table view
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "reportCell"
        )
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl

        filterSearchBar.delegate = self
        filterSearchBar.showsCancelButton = true
        
        reportFilterController.onSelect = { indexPath in
            self.viewModel.lastSelectedLocation = self.reportFilterController.reports[indexPath.row]
        }
        filterResultsTableView.isHidden = true
        filterResultsTableView.dataSource = reportFilterController
        filterResultsTableView.delegate = reportFilterController
        filterResultsTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "reportCell"
        )

        // make sure to add subviews before setting up constraints
        view.addSubview(mapView!)
        view.addSubview(tableView!)
        view.addSubview(filterSearchBar)
        view.addSubview(filterResultsTableView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        mapView?.snp.makeConstraints({ make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(
                viewModel.mapHeightFactor
            )
        })

        filterSearchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(mapView!.snp.bottom)
        }
        
        tableView?.snp.makeConstraints({ make in
            make.leading.trailing.bottom.equalToSuperview()
        })
        
        tableView?.snp.makeConstraints { make in
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
        tableView?.reloadData()
        if let lastSelectedLocation = viewModel.lastSelectedLocation {
            zoom(report: lastSelectedLocation)
        }

        reportFilterController.reports = viewModel.filtered
        filterResultsTableView.reloadData()
    }
    
    func onModelReady(viewModel: T) {
        tableView?.reloadData()
        updateStations()
    }
    
    func updateStations(filterText: String? = nil) {
        let stations = viewModel.getStations(filterText: filterText)
        do {
            mapView?.removeAnnotations(mapView!.annotations)
            mapView?.addAnnotations(
                try stations.map<MKAnnotation>({ (key: String, value: (String, CLLocationCoordinate2D, WaterFlowLevel)) in
                    return SublimeMapAnnotation(
                        title: key.components(separatedBy: CharacterSet(["+"])).first!,
                        coordinate: value.1,
                        flowLevel: value.2
                    )
                }))
        } catch {
            debugPrint(error)
        }
    }
    
    func zoom(report: WaterLevelReport) {
        let coords = report.getLocationCoordinates()
        setRegion(coords: coords)
    }
    
    /// sets zoom region with visible distance spanning a default 10km
    func setRegion(coords: CLLocationCoordinate2D, meters: Double = 10000) {
        mapView?.setRegion(
            MKCoordinateRegion(
                center: coords,
                latitudinalMeters: meters,
                longitudinalMeters: meters
            ),
            animated: true
        )
    }
    
    @objc func beginRefresh() {
        Task.init {
            await viewModel.prepareData()
            refreshControl?.endRefreshing()
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        
        let model = viewModel.reports[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(model.waterbody) @ \(model.station)"
        content.secondaryText = "flow: \(model.speed) m^3/s, depth: \(model.depth) cm"
        cell.contentConfiguration = content
        let image = imageForFlow(flow: model.getFlow())
        cell.accessoryView = image
        return cell
    }
    
    func imageForFlow(flow: WaterFlowLevel) -> UIImageView? {
        var imageView: UIImageView?
        switch flow {
        case .high:
            imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
            imageView?.tintColor = UIColor.red
        case .low:
            imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            imageView?.tintColor = UIColor.green
        default:
            imageView = nil
        }
        return imageView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.lastSelectedLocation = viewModel.reports[indexPath.row]
    }
}

extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        if let sublime = annotation as? SublimeMapAnnotation {
            let view = MKMarkerAnnotationView(
                annotation: sublime,
                reuseIdentifier: "waterStationAnnoation"
            )
            view.glyphText = sublime.title
            annotationView = view
            switch sublime.flowLevel {
            case .low:
                view.markerTintColor = UIColor.green
            case .high:
                view.markerTintColor = UIColor.red
            default:
                view.markerTintColor = UIColor.yellow
            }
            
        }
        return annotationView
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterResultsTableView.isHidden = (searchBar.text?.count ?? 0) < 3
        viewModel.filter(text: searchText)
        if (filterResultsTableView.isHidden) {
            updateStations()
        } else {
            updateStations(filterText: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

class ReportFilterController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var reports = [WaterLevelReport]()
    
    var onSelect: ((IndexPath) -> Void)?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        let model = reports[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(model.waterbody) @ \(model.station)"
        content.secondaryText = "flow: \(model.speed) m^3/s, depth: \(model.depth) cm"
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onSelect = onSelect {
            onSelect(indexPath)
        }
    }
}
