//
//  station_detail_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import UIKit
import SwiftUI
import cleanboot_swift

class StationDetailViewController: UIViewController, BaseViewController {
    
    var controller: StationDetailController
    var chart: water_data_chart?
    var chartContainer: UIView = UIView()
    
    init(controller: StationDetailController, nibName: String? = nil, bundle: Bundle? = nil) {
        self.controller = controller
        super.init(nibName: nibName, bundle: bundle)
        controller.viewModel.onModelReady = self.onModelReady(viewModel:)
        controller.viewModel.onModelUpdate = self.onModelUpdate(viewModel:)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(chartContainer)
        chartContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview { view in
                view.snp.leadingMargin
            }
            make.trailing.equalToSuperview { view in
                view.snp.trailingMargin
            }
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
        }
    }
    
    func setupChart() {
        if (chart == nil) {
            chart = water_data_chart(
                dataPoints: WaterChartData(
                    data: controller.viewModel.chartItems,
                    lastReport: controller.viewModel.stationReport,
                    dataType: controller.viewModel.dataType
                )
            )
            let host = UIHostingController(
                rootView: chart
            )
            host.sizingOptions = .intrinsicContentSize
            host.view.translatesAutoresizingMaskIntoConstraints = false
            self.addChild(host)
            
            chartContainer.addSubview(host.view)
            host.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            host.didMove(toParent: self)
        }
    }
    
    typealias T = StationDetailViewModel
    
    func onModelReady(viewModel: StationDetailViewModel) {
        setupChart()
    }
    
    func onModelUpdate(viewModel: StationDetailViewModel) {
        // stub
    }
    
}
