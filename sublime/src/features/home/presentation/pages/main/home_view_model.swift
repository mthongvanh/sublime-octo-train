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
