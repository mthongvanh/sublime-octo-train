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
    
    var annotations = [SublimeMapAnnotation]()
    
    var mirna = CLLocationCoordinate2D(
        latitude: CLLocationDegrees(
            floatLiteral: 45.95164419436902
        ),
        longitude: CLLocationDegrees(
            floatLiteral: 15.063696548071546
        )
    )
    
    var mapHeightFactor = 0.35
    var mapZoomLevel = 1.25
    var lastSelectedLocation: WaterLevelReport? {
        didSet {
            guard let update = onModelUpdate else {
                return
            }
            
            update(self)
        }
    }
    
    func initialLocation() -> CLLocationCoordinate2D {
        mirna
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
    
    func updateStations(stations: [String: (String, CLLocationCoordinate2D, WaterFlowLevel, String)]) {
        annotations = stations.map<MKAnnotation>({ (key: String, value: (String, CLLocationCoordinate2D, WaterFlowLevel, String)) in
            SublimeMapAnnotation(
                title: key.components(separatedBy: CharacterSet(["+"])).first!,
                coordinate: value.1,
                flowLevel: value.2,
                stationCode: value.3
            )
        })
        if let onModelUpdate = onModelUpdate {
            onModelUpdate(self)
        }
    }
}
