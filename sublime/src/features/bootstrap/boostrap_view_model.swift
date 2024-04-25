//
//  boostrap_view_model.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import Foundation
import cleanboot_iOS

class BootstrapViewModel: ViewModel<BootstrapViewModel> {
    override init(
        onModelReady: OnModelReady<BootstrapViewModel>? = nil,
        onModelUpdate: OnModelUpdate<BootstrapViewModel>? = nil
    ) {
        super.init(
            onModelReady: onModelReady,
            onModelUpdate: onModelUpdate
        )
    }
    
    override func prepareData() async {
        await super.prepareData()
    }
}

