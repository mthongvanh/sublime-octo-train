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
        let stations = viewModel.getStations()
        do {
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
}

class SublimeMapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var flowLevel: WaterFlowLevel
    var title: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, flowLevel: WaterFlowLevel) {
        self.title = title
        self.flowLevel = flowLevel
        self.coordinate = coordinate
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
