//
//  AppDependencyContainer.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import UIKit

final class AppDependencyContainer {
    // Managers
    lazy var storeDataManager: StoreDataManaging = StoreDataManager()
    lazy var dataManager: DataManaging = DataManager(storeManager: storeDataManager)
    lazy var locationManager: LocationManaging = LocationManager()
    
    // View Models
    func makeMainViewModel() -> MainViewModel {
        return MainViewModel(locationManager: locationManager, dataManager: dataManager)
    }

    // Coordinators
    func makeMainCoordinator(navigationController: UINavigationController) -> MainCoordinator {
        return MainCoordinator(
            navigationController: navigationController,
            locationManager: locationManager,
            dataManager: dataManager
        )
    }
}

