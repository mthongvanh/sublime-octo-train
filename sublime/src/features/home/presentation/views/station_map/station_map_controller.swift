//
//  station_map_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import Foundation
import MapKit

class StationMapController: NSObject {
    
    var viewModel: StationMapViewModel
    
    init(viewModel: StationMapViewModel) {
        self.viewModel = viewModel
    }

}


extension StationMapController: MKMapViewDelegate {
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
