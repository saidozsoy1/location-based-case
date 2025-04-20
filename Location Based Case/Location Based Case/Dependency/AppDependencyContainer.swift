//
//  AppDependencyContainer.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import UIKit

// Storage type enum to switch between UserDefaults and CoreData
enum StorageType {
    case userDefaults
    case coreData
}

final class AppDependencyContainer {
    // Storage type selection
    private let storageType: StorageType
    
    // Managers
    lazy var storeDataManager: StoreDataManaging = {
        switch storageType {
        case .userDefaults:
            print("DEBUG: Using UserDefaults for storage")
            return StoreDataManager()
        case .coreData:
            print("DEBUG: Using CoreData for storage")
            return coreDataManager
        }
    }()
    
    lazy var coreDataManager: CoreDataManaging = CoreDataManager()
    
    lazy var dataManager: DataManaging = DataManager(storeManager: storeDataManager)
    lazy var locationManager: LocationManaging = LocationManager()
    
    // Initialization with storage type selection
    init(storageType: StorageType = .coreData) {
        self.storageType = storageType
    }
    
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

