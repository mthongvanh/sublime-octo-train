//
//  station_detail_view_controller.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import UIKit
import cleanboot_swift

class StationDetailViewController: UIViewController, BaseViewController {
    
    var controller: StationDetailController
    
    init(controller: StationDetailController, nibName: String? = nil, bundle: Bundle? = nil) {
        self.controller = controller
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    
    
    
    typealias T = StationDetailViewModel
    
    func onModelReady(viewModel: StationDetailViewModel) {
        // stub
    }

    func onModelUpdate(viewModel: StationDetailViewModel) {
        // stub
    }
    
}
