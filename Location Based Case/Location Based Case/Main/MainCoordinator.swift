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

    init(navigationController: UINavigationController, locationManager: LocationManaging) {
        self.navigationController = navigationController
        self.locationManager = locationManager
    }

    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() as? MainViewController else {
            fatalError("Could not instantiate MainViewController from storyboard")
        }
        
        let viewModel = MainViewModel(locationManager: locationManager)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
    }
}
