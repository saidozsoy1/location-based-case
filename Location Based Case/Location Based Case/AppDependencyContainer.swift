//
//  AppDependencyContainer.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import UIKit

final class AppDependencyContainer {
    lazy var locationManager: LocationManaging = LocationManager()

    func makeMainCoordinator(navigationController: UINavigationController) -> MainCoordinator {
        return MainCoordinator(
            navigationController: navigationController,
            locationManager: locationManager
        )
    }
}

