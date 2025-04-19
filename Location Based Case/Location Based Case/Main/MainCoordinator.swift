//
//  MainCoordinator.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import UIKit

final class MainCoordinator {
    private let navigationController: UINavigationController
    private let locationManager: LocationManaging
    private let dataManager: DataManaging

    init(navigationController: UINavigationController, locationManager: LocationManaging, dataManager: DataManaging) {
        self.navigationController = navigationController
        self.locationManager = locationManager
        self.dataManager = dataManager
    }

    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() as? MainViewController else {
            fatalError("Could not instantiate MainViewController from storyboard")
        }
        
        let viewModel = MainViewModel(locationManager: locationManager, dataManager: dataManager)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
    }
}
