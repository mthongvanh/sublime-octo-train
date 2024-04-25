//
//  sublime_annotation.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/25/24.
//

import Foundation
import MapKit

class SublimeMapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var flowLevel: WaterFlowLevel
    var title: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, flowLevel: WaterFlowLevel) {
        self.title = title
        self.flowLevel = flowLevel
        self.coordinate = coordinate
    }
}
