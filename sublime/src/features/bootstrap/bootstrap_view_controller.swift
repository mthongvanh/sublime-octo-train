//
//  BootstrapViewController.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/22/24.
//

import UIKit
import SnapKit
import cleanboot_swift

class BootstrapViewController: UIViewController {
    
    var viewModel: BootstrapViewModel? = nil
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupViews()
        self.viewModel = BootstrapViewModel(
            onModelReady: self.onModelReady,
            onModelUpdate: self.onModelUpdate
        )
        self.bootstrap()
    }
    
    // init
    func setupViews() {
        view.backgroundColor = UIColor.orange
        
        activityIndicator.startAnimating()
        let container = UIView()
        container.backgroundColor = UIColor.blue
        container.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }
    
    func bootstrap() {
        Task.init {
            let serviceLocator = AppServiceLocator.shared
            await DependencyInjector().bootstrap(
                serviceLocator: serviceLocator
            )            
            DispatchQueue.main.async {
                self.continueToApp(serviceLocator)
            }
        }
    }
    
    //View Model management
    func setupViewModel() {
        viewModel = BootstrapViewModel(
            onModelReady: onModelReady,
            onModelUpdate: onModelUpdate
        )
    }
    
    func onModelReady(viewModel: BootstrapViewModel) -> Void {
        activityIndicator.stopAnimating()
    }
    
    func onModelUpdate(viewModel: BootstrapViewModel) -> Void {
        debugPrint(viewModel)
    }
    
    // navigation
    private func continueToApp(_ serviceLocator: AppServiceLocator) {
        do {
            guard let keyWindow = UIApplication.shared.firstKeyWindow else {
                throw URLError(.badServerResponse, userInfo: ["bad": "keyWindow was nil"])
            }
            
            keyWindow.rootViewController = UINavigationController(
                rootViewController: try serviceLocator.get(
                    serviceType: HomeViewController.self
                )
            )
            keyWindow.makeKeyAndVisible()
        } catch {
            debugPrint(error)
        }
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
        
    }
}
