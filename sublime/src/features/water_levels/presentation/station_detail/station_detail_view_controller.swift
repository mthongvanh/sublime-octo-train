//
//  station_detail_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import UIKit
import SwiftUI
import cleanboot_swift
import SkeletonView

class StationDetailViewController: UIViewController, BaseViewController {
    
    var controller: StationDetailController
    
    var chart: water_data_chart?
    var chartContainer: UIView = UIView()
    var chartHost: UIHostingController<water_data_chart>?
    
    var dataTypeControl: UISegmentedControl?
    var observationSpanControl: UISegmentedControl?
    
    init(
        controller: StationDetailController,
        nibName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.controller = controller
        super.init(
            nibName: nibName,
            bundle: bundle
        )
        
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
        do {
            view.backgroundColor = UIColor.systemBackground
            
            /// setup data type picker
            dataTypeControl = try buildDataTypePicker()
            view.addSubview(dataTypeControl!)
            dataTypeControl!.snp.makeConstraints { make in
                make.top.equalToSuperview { superView in
                    superView.snp_topMargin
                }
                make.leading.equalToSuperview { superView in
                    superView.snp.leadingMargin
                }
                make.trailing.equalToSuperview { superView in
                    superView.snp.trailingMargin
                }
            }
            
            /// setup chart container
            chartContainer.isSkeletonable = true
            chartContainer.skeletonCornerRadius = 10
            chartContainer.showAnimatedGradientSkeleton(
                animation: SkeletonAnimationBuilder().makeSlidingAnimation(
                    withDirection: .topLeftBottomRight
                )
            )
            
            view.addSubview(chartContainer)
            chartContainer.snp.makeConstraints { make in
                make.top.equalTo(dataTypeControl!.snp.bottom).offset(20)
                make.leading.equalToSuperview { view in
                    view.snp.leadingMargin
                }
                make.trailing.equalToSuperview { view in
                    view.snp.trailingMargin
                }
                make.height.equalTo(view.snp.height).multipliedBy(0.33)
            }
            
            let spanLabel = UILabel()
            spanLabel.text = "Viewing data for the following period:"
            spanLabel.font = .preferredFont(forTextStyle: .headline)


            view.addSubview(spanLabel)
            spanLabel.snp.makeConstraints { make in
                make.top.equalTo(chartContainer.snp.bottom).offset(20)
                make.leading.equalToSuperview { superView in
                    superView.snp.leadingMargin
                }
                make.trailing.equalToSuperview { superView in
                    superView.snp.trailingMargin
                }
            }
            
            /// setup data type picker
            observationSpanControl = try buildObservationSpanPicker()
            view.addSubview(observationSpanControl!)
            observationSpanControl!.snp.makeConstraints { make in
                make.top.equalTo(spanLabel.snp.bottom).offset(10)
                make.leading.equalToSuperview { superView in
                    superView.snp.leadingMargin
                }
                make.trailing.equalToSuperview { superView in
                    superView.snp.trailingMargin
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func setupChart() {
        /// cleanup old hosting controller and chart
        if (chartHost != nil) {
            chartHost?.removeFromParent()
            chartHost?.view.removeFromSuperview()
            chart = nil
        }
        
        /// setup new chart instance with hosting controller
        chart = water_data_chart(
            dataPoints: WaterChartData(
                data: controller.viewModel.chartItems,
                lastReport: controller.viewModel.stationReport,
                dataType: controller.viewModel.dataType
            )
        )
        
        let host = UIHostingController(
            rootView: chart!
        )
        host.sizingOptions = .intrinsicContentSize
        host.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(host)
        
        chartContainer.addSubview(host.view)
        host.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        host.didMove(toParent: self)
        
        chartHost = host
    }
    
    func buildDataTypePicker() throws -> UISegmentedControl {
        let control = UISegmentedControl(frame: CGRectZero)
        let actions = try WaterLevelValueType.allCases.map<UIAction>({ type in
            UIAction(title: type.rawValue.capitalized, handler: { action in
                self.controller.handleDataTypeControlChange(control: control)
            })
        })
        
        actions.indices.forEach { index in
            control.insertSegment(action: actions[index], at: index, animated: false)
        }
        
        control.selectedSegmentIndex = 0
        return control
    }
    
    func buildObservationSpanPicker() throws -> UISegmentedControl {
        let control = UISegmentedControl(frame: CGRectZero)
        var selectedIndex = 0
        let spans = controller.viewModel.availableSpanLengths()
        let actions = try spans.indices.map<UIAction> { index in
            let span = spans[index]
            
            if span == controller.viewModel.dataSpan {
                selectedIndex = index
            }
            
            return UIAction(
                title: "\(span.rawValue) \(span.rawValue == 1 ? "day" : "days")",
                handler: { action in
                    self.controller.handleObservationSpanControlChange(
                        control: control
                    )
                }
            )
        }
        
        actions.indices.forEach { index in
            control.insertSegment(
                action: actions[index],
                at: index,
                animated: false
            )
        }
        
        control.selectedSegmentIndex = selectedIndex
        return control
    }
    
    typealias T = StationDetailViewModel
    
    func onModelReady(viewModel: StationDetailViewModel) {
        setupChart()
    }
    
    func onModelUpdate(viewModel: StationDetailViewModel) {
        if viewModel.loading {
            chartContainer.showAnimatedGradientSkeleton(
                animation: SkeletonAnimationBuilder().makeSlidingAnimation(
                    withDirection: .topLeftBottomRight
                )
            )
        } else {
            chartContainer.hideSkeleton()
            setupChart()
        }
    }
    
}
