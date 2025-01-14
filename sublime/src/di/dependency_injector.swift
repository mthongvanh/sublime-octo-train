import Foundation
import cleanboot_swift

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
                baseURL: "https://www.arso.gov.si")
        )
        
        let localDataSource = WaterLevelLocalDataSourceImpl()
        
        let repo = WaterLevelRepositoryImpl(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource
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
        
        try serviceLocator.registerFactory(
            instantiator: { parameters in
                GetHistoricalDataUseCase(
                    repo: try serviceLocator.get(
                        serviceType: WaterLevelRepository.self,
                    identifier: nil,
                    parameters: nil
                )
            )},
            type: GetHistoricalDataUseCase.self,
            identifier: nil
        )
        
        try serviceLocator.registerFactory(
            instantiator: { parameters in
                ToggleFavoriteStationUseCase(
                    repo: try serviceLocator.get(
                        serviceType: WaterLevelRepository.self,
                    identifier: nil,
                    parameters: nil
                )
            )},
            type: ToggleFavoriteStationUseCase.self,
            identifier: nil
        )
        
        try serviceLocator.registerFactory(
            instantiator: { parameters in
                GetFavoriteStatusUseCase(
                    repo: try serviceLocator.get(
                        serviceType: WaterLevelRepository.self,
                    identifier: nil,
                    parameters: nil
                )
            )},
            type: GetFavoriteStatusUseCase.self,
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
                        let hvc = HomeViewController(
                            viewModel: homeVM
                        )
                        homeVM.onModelReady = hvc.onModelReady(viewModel:)
                        homeVM.onModelUpdate = hvc.onModelUpdate(viewModel:)
                        return hvc
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
