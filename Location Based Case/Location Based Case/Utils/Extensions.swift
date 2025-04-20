//
//  Extensions.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import UIKit

// MARK: - UIViewController Extension
extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        AlertManager.showAlert(on: self, title: title, message: message, completion: completion)
    }
    
    func showAddressAlert(address: String?) {
        AlertManager.showAddressAlert(on: self, address: address)
    }
    
    func showErrorAlert(error: Error) {
        AlertManager.showErrorAlert(on: self, error: error)
    }
    
    func showLocationErrorAlert(error: Error) {
        AlertManager.showLocationErrorAlert(on: self, error: error)
    }
    
    func showPermissionAlert() {
        AlertManager.showPermissionAlert(
            on: self,
            title: "Location Permission Required",
            message: "Please enable location permissions in settings to use tracking feature."
        )
    }
}

extension Notification.Name {
    static let appWillEnterForeground = Notification.Name(rawValue: "AppWillEnterForeground")
    static let appDidEnterBackground = Notification.Name(rawValue: "AppDidEnterBackground")
}
