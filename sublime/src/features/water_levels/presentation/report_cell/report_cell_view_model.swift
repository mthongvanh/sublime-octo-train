//
//  report_cell_view_model.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/28/24.
//

import UIKit
import cleanboot_swift

class ReportCellViewModel: ViewModel<ReportCellViewModel> {
    var report: WaterLevelReport
    init(
        report: WaterLevelReport,
        onReady: OnModelReady<ReportCellViewModel>? = nil,
        onUpdate: OnModelUpdate<ReportCellViewModel>? = nil
    ) {
        self.report = report
        super.init(onModelReady: onReady, onModelUpdate: onUpdate)
    }
    
    func text() -> String {
        "\(report.waterbody) @ \(report.station)"
    }
    
    func secondaryText() -> String {
        "flow: \(report.speed) m^3/s, depth: \(report.depth) cm"
    }
    
    func imageForFlow() -> UIImageView? {
        var imageView: UIImageView?
        switch report.getFlow() {
        case .high:
            imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
            imageView?.tintColor = UIColor.red
        case .low:
            imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            imageView?.tintColor = UIColor.green
        default:
            imageView = nil
        }
        return imageView
    }
}
