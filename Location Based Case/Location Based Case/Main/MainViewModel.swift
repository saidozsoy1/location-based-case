//
//  MainViewModel.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import Foundation
import CoreLocation
import MapKit
import UIKit

enum LocationTrackingError: Error {
    case permissionDenied
    case locationServicesDisabled
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return L10n.Error.permissionDenied
        case .locationServicesDisabled:
            return L10n.Error.servicesDisabled
        case .unknown:
            return L10n.Error.unknown
        }
    }
}

enum TrackingPermissionStatus {
    case permitted
    case denied
    case restricted
    case undetermined
}

protocol MainViewModelDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
    func didChangeAuthorizationStatus(statusText: String?)
    func didFailWithError(_ error: Error)
    func didAddRoutePoint(_ location: CLLocation)
    func didLoadSavedRoute(_ locations: [CLLocation])
    func didTrackingChange(_ isTrackingActive: Bool, trackingButtonText: String)
    func didRetrieveAddress(for annotation: RouteAnnotation, address: String?)
    func showPermissionAlert()
}

final class MainViewModel {
    private var locationManager: LocationManaging
    private var dataManager: DataManaging
    weak var delegate: MainViewModelDelegate?
    
    // Custom queue for location operations
    private let locationQueue = DispatchQueue(label: "com.locationbasedcase.locationOperationsQueue")
    
    private var isTrackingActive = false {
        didSet {
            let trackingButtonText = isTrackingActive ? 
                L10n.Button.stopTracking : 
                L10n.Button.startTracking
            delegate?.didTrackingChange(isTrackingActive, trackingButtonText: trackingButtonText)
        }
    }
    
    var currentLocation: CLLocation? {
        return locationManager.lastLocation
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    private var routePoints: [CLLocation] = []
    private let minimumDistanceThreshold: CLLocationDistance = 100
    
    init(locationManager: LocationManaging, dataManager: DataManaging) {
        self.locationManager = locationManager
        self.dataManager = dataManager
        self.locationManager.delegate = self
        loadSavedRoute()
    }
    
    func getPermissionStatus() -> TrackingPermissionStatus {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .permitted
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .undetermined
        @unknown default:
            return .undetermined
        }
    }
    
    func startTracking() {
        // First, check if location services are enabled using custom queue
        locationQueue.async { [weak self] in
            if !CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailWithError(LocationTrackingError.locationServicesDisabled)
                }
                return
            }
            
            // Continue on main thread for UI operations
            DispatchQueue.main.async { [weak self] in
                // Check authorization status
                switch self?.getPermissionStatus() {
                case .permitted:
                    // Permission granted, start updating
                    self?.isTrackingActive = true
                    self?.locationManager.startUpdatingLocation()
                case .denied, .restricted:
                    // Need to show permission alert
                    self?.delegate?.showPermissionAlert()
                case .undetermined:
                    // Request permission
                    self?.requestAlwaysPermission()
                    // Will start updating after permission is granted
                case .none:
                    break
                }
            }
        }
    }
    
    func stopTracking() {
        isTrackingActive = false
        locationManager.stopUpdatingLocation()
    }
    
    func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }
    
    func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    var isTracking: Bool {
        return isTrackingActive
    }
    
    func resetRoute() {
        routePoints.removeAll()
        dataManager.clearRoutePoints()
        delegate?.didLoadSavedRoute([])
    }
    
    private func shouldAddLocation(_ location: CLLocation) -> Bool {
        guard let lastLocation = routePoints.last else {
            return true // Add first point always
        }
        
        let distance = location.distance(from: lastLocation)
        return distance >= minimumDistanceThreshold
    }
    
    private func saveRoutePoint(_ location: CLLocation) {
        routePoints.append(location)
        delegate?.didAddRoutePoint(location)
        saveRoute()
    }
    
    private func saveRoute() {
        do {
            let routePointModels = dataManager.convertToRoutePoints(routePoints)
            try dataManager.saveRoutePoints(routePointModels)
        } catch {
            print("Error saving route: \(error)")
        }
    }
    
    func loadSavedRoute() {
        do {
            guard let routePointModels = try dataManager.loadRoutePoints() else {
                return
            }
            
            let locations = dataManager.convertToLocations(routePointModels)
            routePoints = locations
            delegate?.didLoadSavedRoute(locations)
        } catch {
            print("Error loading route: \(error)")
        }
    }
    
    // MARK: - Geocoding
    
    func getAddressForAnnotation(_ annotation: RouteAnnotation) {
        let location = CLLocation(
            coordinate: annotation.coordinate,
            altitude: 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            timestamp: Date()
        )
        
        dataManager.getAddressFromLocation(location) { [weak self] address, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting address: \(error.localizedDescription)")
            }
            
            self.delegate?.didRetrieveAddress(for: annotation, address: address)
        }
    }
}

extension MainViewModel: LocationManagerDelegate {
    func didUpdateLocations(_ locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocation(location)
        
        if shouldAddLocation(location) {
            saveRoutePoint(location)
        }
    }
    
    func didChangeAuthorizationStatus(_ status: CLAuthorizationStatus) {
        var statusText = ""
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
            statusText = L10n.Status.permissionGranted
            // If user just granted permission and we were waiting, start tracking
            if !isTracking {
                startTracking()
            }
        case .denied:
            statusText = L10n.Status.permissionDenied
            // If permission is denied while tracking, stop tracking
            if isTrackingActive {
                stopTracking()
                delegate?.didFailWithError(LocationTrackingError.permissionDenied)
            }
        case .restricted:
            statusText = L10n.Status.restricted
            // If access is restricted while tracking, stop tracking
            if isTrackingActive {
                stopTracking()
                delegate?.didFailWithError(LocationTrackingError.permissionDenied)
            }
        case .notDetermined:
            statusText = L10n.Status.waiting
        @unknown default:
            statusText = L10n.Status.unknown
        }
        delegate?.didChangeAuthorizationStatus(statusText: statusText)
    }
    
    func didFailWithError(_ error: Error) {
        // If we get any location error, stop tracking
        if isTrackingActive {
            stopTracking()
        }
        delegate?.didFailWithError(error)
    }
}
