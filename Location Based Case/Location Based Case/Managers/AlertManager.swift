//
//  AlertManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import UIKit

final class AlertManager {
    static func showAlert(on viewController: UIViewController, title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: L10n.Alert.okay, style: .default) { _ in
            completion?()
        })
        
        viewController.present(alert, animated: true)
    }
    
    static func showAddressAlert(on viewController: UIViewController, address: String?) {
        let message = address ?? L10n.Alert.addressNotFound
        showAlert(on: viewController, title: L10n.Alert.locationInfoTitle, message: message)
    }
    
    static func showErrorAlert(on viewController: UIViewController, error: Error) {
        showAlert(on: viewController, title: L10n.Error.title, message: error.localizedDescription)
    }
    
    static func showLocationErrorAlert(on viewController: UIViewController, error: Error) {
        let message = L10n.Error.failedToGetLocation(error.localizedDescription)
        showAlert(on: viewController, title: L10n.Error.locationTitle, message: message)
    }
    
    static func showPermissionAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: L10n.Alert.permissionCancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Alert.permissionSettings, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        viewController.present(alert, animated: true)
    }
}
