//
//  station_map_view_model.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import Foundation
import MapKit
import cleanboot_swift

class StationMapViewModel: ViewModel<StationMapViewModel> {
    
    override init(
        onModelReady: OnModelReady<StationMapViewModel>? = nil,
        onModelUpdate: OnModelUpdate<StationMapViewModel>? = nil
    ) {
        super.init(
            onModelReady: onModelReady,
            onModelUpdate: onModelUpdate
        )
    }
    
    var ljubljana = CLLocationCoordinate2D(
        latitude: CLLocationDegrees(
            floatLiteral: 46.05108000
        ),
        longitude: CLLocationDegrees(
            floatLiteral: 14.50513000
        )
    )
    
    var mapHeightFactor = 0.35
    var mapZoomLevel = 0.5
    var lastSelectedLocation: WaterLevelReport? {
        didSet {
            guard let update = onModelUpdate else {
                return
            }
            
            update(self)
        }
    }
    
    func initialLocation() -> CLLocationCoordinate2D {
        ljubljana
    }
    
    func initialRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: initialLocation(),
            span: MKCoordinateSpan(
                latitudeDelta: CLLocationDegrees(
                    mapZoomLevel
                ),
                longitudeDelta: CLLocationDegrees(
                    mapZoomLevel
                )
            )
        )
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
