//
//  LocalizationKeys.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import Foundation

enum L10n {
    // Error Messages
    enum Error {
        static var permissionDenied: String {
            return NSLocalizedString("errorPermissionDenied", comment: "Error message when location permission is denied")
        }
        
        static var servicesDisabled: String {
            return NSLocalizedString("errorServicesDisabled", comment: "Error message when location services are disabled")
        }
        
        static var unknown: String {
            return NSLocalizedString("errorUnknown", comment: "Unknown location error message")
        }
        
        static var title: String {
            return NSLocalizedString("error", comment: "Error title")
        }
        
        static var locationTitle: String {
            return NSLocalizedString("locationError", comment: "Location Error title")
        }
        
        static func failedToGetLocation(_ errorMessage: String) -> String {
            return String(format: NSLocalizedString("failedToGetLocation", comment: "Failed to get location format"), errorMessage)
        }
    }
    
    // Location Status
    enum Status {
        static var permissionGranted: String {
            return NSLocalizedString("statusPermissionGranted", comment: "Location permission granted")
        }
        
        static var permissionDenied: String {
            return NSLocalizedString("statusPermissionDenied", comment: "Location permission denied")
        }
        
        static var restricted: String {
            return NSLocalizedString("statusRestricted", comment: "Location access is restricted")
        }
        
        static var waiting: String {
            return NSLocalizedString("statusWaiting", comment: "Waiting for location permission")
        }
        
        static var unknown: String {
            return NSLocalizedString("statusUnknown", comment: "Unknown location authorization status")
        }
    }
    
    // Buttons
    enum Button {
        static var startTracking: String {
            return NSLocalizedString("buttonStartTracking", comment: "Start tracking button")
        }
        
        static var stopTracking: String {
            return NSLocalizedString("buttonStopTracking", comment: "Stop tracking button")
        }
        
        static var resetRoute: String {
            return NSLocalizedString("buttonResetRoute", comment: "Reset route button")
        }
    }
    
    // Labels
    enum Label {
        static func latitude(_ value: String) -> String {
            return String(format: NSLocalizedString("labelLatitude", comment: "Latitude format"), value)
        }
        
        static func longitude(_ value: String) -> String {
            return String(format: NSLocalizedString("labelLongitude", comment: "Longitude format"), value)
        }
    }
    
    // Alerts
    enum Alert {
        static var permissionTitle: String {
            return NSLocalizedString("alertPermissionTitle", comment: "Location permission alert title")
        }
        
        static var permissionMessage: String {
            return NSLocalizedString("alertPermissionMessage", comment: "Location permission alert message")
        }
        
        static var permissionSettings: String {
            return NSLocalizedString("alertPermissionSettings", comment: "Settings button in permission alert")
        }
        
        static var permissionCancel: String {
            return NSLocalizedString("alertPermissionCancel", comment: "Cancel button in permission alert")
        }
        
        static var locationInfoTitle: String {
            return NSLocalizedString("locationInfo", comment: "Location Info title")
        }
        
        static var addressNotFound: String {
            return NSLocalizedString("addressNotFound", comment: "Address not found message")
        }
        
        static var okay: String {
            return NSLocalizedString("OK", comment: "OK")
        }
    }
}
