//
//  home_view_model.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import Foundation
import cleanboot_swift
import MapKit

class HomeViewModel: ViewModel<HomeViewModel> {
    
    var getWaterLevels: GetWaterLevelsUseCase
    
    var reports = [WaterLevelReport]()
    var filtered = [WaterLevelReport]()
    
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
    
    init(
        getWaterLevels: GetWaterLevelsUseCase,
        onModelReady: OnModelReady<HomeViewModel>? = nil,
        onModelUpdate: OnModelUpdate<HomeViewModel>? = nil
    ) {
        self.getWaterLevels = getWaterLevels
        super.init(onModelReady: onModelReady, onModelUpdate: onModelUpdate)
    }
    
    override func prepareData() async {
        
        updateLoadState(loadState: .loading)
        
        let water = WaterLevelRemoteDataSourceImpl(
            waterLevelAPI: WaterLevelAPI(
                environment: .development,
                baseURL: "https://www.arso.gov.si"
            )
        )
        
        do {
            reports = try await water.getWaterLevels().map<WaterLevelReport>({ model in
                model.toEntity()
            })
            reports.sort { $0.waterbody < $1.waterbody }
            
            DispatchQueue.main.async {
                guard let modelReady = self.onModelReady else {
                    self.updateLoadState(loadState: .error)
                    return;
                }
                
                self.loadState = self.reports.isEmpty ? .readyNoData : .ready
                modelReady(self)
            }
        } catch {
            updateLoadState(loadState: .error)
        }
    }
    
    func getStations(filterText: String? = nil) -> [String: (String, CLLocationCoordinate2D, WaterFlowLevel)] {
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
    
    func filter(text: String) {
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = text.trimmingCharacters(in: whitespaceCharacterSet)
        
        filtered = reports.compactMap({ report in
            if (report.waterbody.range(
                of: strippedString,
                options: [.caseInsensitive]
            )?.isEmpty == false
                || report.station.range(
                    of: strippedString,
                    options: [.caseInsensitive]
                )?.isEmpty == false)
            {
                return report
            } else {
                return nil
            }
        })
        
        DispatchQueue.main.async {
            guard let update = self.onModelUpdate else {
                return;
            }
            
            update(self)
        }
        
    }
}
