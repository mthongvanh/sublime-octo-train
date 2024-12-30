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
    var didSelectAnnotation: ((SublimeMapAnnotation) -> Void)?
    
    init(viewModel: StationMapViewModel, didSelectAnnotation: ((SublimeMapAnnotation) -> Void)?) {
        self.viewModel = viewModel
        self.didSelectAnnotation = didSelectAnnotation
    }
    
    func updateStations(filterText: String? = nil, reports: [WaterLevelReport]) {
        let stations = getStations(filterText: filterText, reports: reports)
        viewModel.updateStations(stations: stations)
    }

    func getStations(filterText: String? = nil, reports: [WaterLevelReport]) -> [String: (String, CLLocationCoordinate2D, WaterFlowLevel, String)] {
        var stations = [String: (String, CLLocationCoordinate2D, WaterFlowLevel, String)]()
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
                    (report.station, location, report.getFlow(), report.stationCode),
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
            view.glyphImage = UIImage(systemName: "figure.fishing")
            annotationView = view
            switch sublime.flowLevel {
            case .low:
                view.markerTintColor = UIColor.systemGreen
            case .high:
                view.markerTintColor = UIColor.systemRed
            default:
                view.markerTintColor = UIColor.yellow
            }
            
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
        if let callback = didSelectAnnotation, let sublime = annotation as? SublimeMapAnnotation {
            callback(sublime)
        }
    }
}
