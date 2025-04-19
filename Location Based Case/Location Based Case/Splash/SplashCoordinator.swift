//
//  SplashCoordinator.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import UIKit

final class SplashCoordinator {
    private let navigationController: UINavigationController
    private let dependencyContainer: AppDependencyContainer
    private let onFinish: () -> Void

    init(
        navigationController: UINavigationController,
        dependencyContainer: AppDependencyContainer,
        onFinish: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.onFinish = onFinish
    }

    func start() {
        let storyboard = UIStoryboard(name: "Splash", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? SplashViewController else {
            fatalError("Could not instantiate SplashViewController from storyboard")
        }
        
        vc.onFinish = { [weak self] in
            self?.onFinish()
        }

        navigationController.setViewControllers([vc], animated: false)
    }
}
