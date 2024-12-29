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
        setupMapView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    func setupMapView() {
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
    }
    
    func onModelUpdate(viewModel: StationMapViewModel) {
        if let coords = viewModel.lastSelectedLocation?.getLocationCoordinates() {
            setRegion(coords: coords)
        }
        
        updateAnnotations(viewModel: viewModel)
    }
    
    func updateAnnotations(viewModel: StationMapViewModel) {
        if let mapViewAnnotations = mapView.annotations as? [SublimeMapAnnotation] {
            let updatedAnnotations = viewModel.annotations
            for annotation in updatedAnnotations {
                if (!mapViewAnnotations.contains(annotation)) {
                    mapView.addAnnotation(annotation)
                }
            }
            
            mapView.removeAnnotations(mapViewAnnotations.compactMap({ displayedAnnotation in
                /// remove any currently displayed annotations which are not in the updated annotation list
                if (!updatedAnnotations.contains(displayedAnnotation)) {
                    return displayedAnnotation
                } else {
                    return nil
                }
            }))
        }
    }
}
