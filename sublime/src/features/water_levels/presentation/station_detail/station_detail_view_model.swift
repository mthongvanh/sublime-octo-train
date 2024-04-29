//
//  station_detail_view_model.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import Foundation
import cleanboot_swift
import SwiftSoup

class StationDetailViewModel: ViewModel<StationDetailViewModel> {

    var getHistoricalDataUseCase: GetHistoricalDataUseCase
    
    init(
        historicalData: GetHistoricalDataUseCase,
        onModelReady: OnModelReady<StationDetailViewModel>? = nil,
        onModelUpdate: OnModelUpdate<StationDetailViewModel>? = nil
    ) {
        getHistoricalDataUseCase = historicalData
        super.init(
            onModelReady: onModelReady,
            onModelUpdate: onModelUpdate
        )
    }
    
    override func prepareData() async {
        updateLoadState(loadState: .loading)
        var hasData = false
        var result: UseCaseResult<[HistoricalDataPoint]>
        do {
            result = try await getHistoricalDataUseCase.execute(params: (.sevenDays, "6060"))
            switch result {
            case .success:
                print(result)
            default:
                debugPrint(result)
            }
        } catch let error {
            updateLoadState(loadState: .error)
//            self.error = error
        }
        
        
        updateLoadState(loadState: hasData ? .ready : .readyNoData)
    }
}
