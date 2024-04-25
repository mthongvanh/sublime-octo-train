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
}
