//
//  station_detail_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import UIKit

class StationDetailController: NSObject {
    var viewModel: StationDetailViewModel
    init(viewModel: StationDetailViewModel) {
        self.viewModel = viewModel
    }
    
    func handleDataTypeControlChange(control: UISegmentedControl) {
        Task.init {
            do {
                let _ = try await viewModel.filterWaterReports(span: viewModel.dataSpan, dataType: .allCases[control.selectedSegmentIndex])
                DispatchQueue.main.async {
                    self.viewModel.onModelUpdate?(self.viewModel)
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func handleObservationSpanControlChange(control: UISegmentedControl) {
        Task.init {
            do {
                let span = await viewModel.availableSpanLengths()[control.selectedSegmentIndex]
                viewModel.dataSpan = span
                viewModel.updateLoadState(loadState: .loading)
                let hasData = try await viewModel.fetchData(
                    span: span,
                    dataType: viewModel.dataType
                )
                
                viewModel.updateLoadState(
                    loadState: hasData ? .ready : .readyNoData
                )
            } catch {
                debugPrint(error)
                viewModel.updateLoadState(
                    loadState: .error
                )
            }
        }
    }
}
