import Foundation
import cleanboot_iOS

class DependencyInjector {
    public func bootstrap(serviceLocator: ServiceLocator) async {
        do {
            
            try registerData(serviceLocator)
            try registerPages(serviceLocator)
            
        } catch {
            debugPrint("error registering dependencies \(error)")
        }
    }
    
    func registerData(_ serviceLocator: ServiceLocator) throws {
        let remoteDataSource = WaterLevelRemoteDataSourceImpl(
            waterLevelAPI: WaterLevelAPI(
                environment: .development,
                baseURL: "https://arso.gov.si")
        )
        
        let repo = WaterLevelRepositoryImpl(
            remoteDataSource: remoteDataSource
        )
        
        try serviceLocator.registerSingleton(
            instance: repo,
            identifier: nil
        )
        
        try serviceLocator.registerFactory(
            instantiator: { parameters in
                GetWaterLevelsUseCase(
                    repo: try serviceLocator.get(
                        serviceType: WaterLevelRepository.self,
                    identifier: nil,
                    parameters: nil
                )
            )},
            type: GetWaterLevelsUseCase.self,
            identifier: nil
        )
    }
    
    func registerPages(_ serviceLocator: ServiceLocator) throws {
        let homeVM = HomeViewModel(
            getWaterLevels: try serviceLocator.get(
                serviceType: GetWaterLevelsUseCase.self,
                identifier: nil,
                parameters: (["hi":"whatsup" as AnyObject], nil)
            )
        )
        
        try serviceLocator.registerSingleton(
            instance: homeVM,
            identifier: nil
        )
        
        DispatchQueue.main.async {
            do {
                try serviceLocator.registerLazySingleton(
                    instantiator: {
                        HomeViewController(
                            viewModel: homeVM
                        )
                    },
                    type: HomeViewController.self,
                    identifier: nil
                )
            } catch {
                debugPrint("error while registering home view controller\n\(error)")
            }
        }
    }
}
