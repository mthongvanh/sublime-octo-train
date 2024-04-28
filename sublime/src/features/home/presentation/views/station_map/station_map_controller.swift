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
    
    func updateStations(filterText: String? = nil, reports: [WaterLevelReport]) {
        let stations = getStations(filterText: filterText, reports: reports)
        viewModel.updateStations(stations: stations)
    }

    func getStations(filterText: String? = nil, reports: [WaterLevelReport]) -> [String: (String, CLLocationCoordinate2D, WaterFlowLevel)] {
        var stations = [String: (String, CLLocationCoordinate2D, WaterFlowLevel)]()
        for report in reports {
            let key = "\(report.waterbody) @ \(report.station)+\(report.latitude)+\(report.longitude)"
            let matchesFilter = filterText == nil ? true : !(key.range(of: filterText!.trimmingCharacters(in: CharacterSet.whitespaces), options: [.caseInsensitive])?.isEmpty ?? true)
            if (!stations.keys.contains(key) && matchesFilter) {
                let location = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(
                        floatLiteral: report.latitude
                    ),
                    longitude: CLLocationDegrees(
                        floatLiteral: report.longitude
                    )
                )
                
                stations.updateValue(
                    (report.station, location, report.getFlow()),
                    forKey: key
                )
            }
        }
        return stations
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
