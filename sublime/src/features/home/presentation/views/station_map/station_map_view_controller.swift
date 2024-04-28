//
//  station_map_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import UIKit
import MapKit
import cleanboot_swift

class StationMapViewController: UIViewController, BaseViewController {
    
    var mapView = MKMapView()
    
    var controller: StationMapController
    
    init(mapView: MKMapView = MKMapView(), controller: StationMapController, nibName: String? = nil, bundle: Bundle? = nil) {
        self.mapView = mapView
        self.controller = controller
        super.init(nibName: nibName, bundle: bundle)
        
        controller.viewModel.onModelReady = onModelReady(viewModel:)
        controller.viewModel.onModelUpdate = onModelUpdate(viewModel:)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup map view
        mapView.delegate = controller;
        mapView.setRegion(
            controller.viewModel.initialRegion(),
            animated: false
        )
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: "waterStationAnnoation"
        )
    }
    
    func updateStations(filterText: String? = nil, reports: [WaterLevelReport]) {
        let stations = controller.viewModel.getStations(filterText: filterText, reports: reports)
        do {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(
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
    
    func zoom() {
        if let coords = controller.viewModel.lastSelectedLocation?.getLocationCoordinates() {
            setRegion(coords: coords)
        }
    }
    
    /// sets zoom region with visible distance spanning a default 10km
    func setRegion(coords: CLLocationCoordinate2D, meters: Double = 10000) {
        mapView.setRegion(
            MKCoordinateRegion(
                center: coords,
                latitudinalMeters: meters,
                longitudinalMeters: meters
            ),
            animated: true
        )
    }
    
    typealias T = StationMapViewModel
    
    func onModelReady(viewModel: StationMapViewModel) {
        //stub
//        zoom()
    }
    
    func onModelUpdate(viewModel: StationMapViewModel) {
        zoom()
    }
}
