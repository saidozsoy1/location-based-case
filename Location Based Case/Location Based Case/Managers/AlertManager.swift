//
//  AlertManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import UIKit

class AlertManager {
    static func showAlert(on viewController: UIViewController, title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        
        viewController.present(alert, animated: true)
    }
    
    static func showAddressAlert(on viewController: UIViewController, address: String?) {
        let message = address ?? "Address not found."
        showAlert(on: viewController, title: "Location Info", message: message)
    }
    
    static func showErrorAlert(on viewController: UIViewController, error: Error) {
        showAlert(on: viewController, title: "Error", message: error.localizedDescription)
    }
    
    static func showLocationErrorAlert(on viewController: UIViewController, error: Error) {
        showAlert(on: viewController, title: "Location Error", message: "Failed to get location: \(error.localizedDescription)")
    }
}
