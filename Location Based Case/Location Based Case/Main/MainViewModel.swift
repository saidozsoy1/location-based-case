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

protocol MainViewModelDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
    func didChangeAuthorizationStatus(statusText: String?)
    func didFailWithError(_ error: Error)
    func didAddRoutePoint(_ location: CLLocation)
    func didLoadSavedRoute(_ locations: [CLLocation])
    func didTrackingChange(_ isTrackingActive: Bool)
    func didRetrieveAddress(for annotation: RouteAnnotation, address: String?)
    func didUpdateLocationForAddress(_ location: CLLocation?)
}

final class MainViewModel {
    private var locationManager: LocationManaging
    private var dataManager: DataManaging
    weak var delegate: MainViewModelDelegate?
    
    private var isTrackingActive = false {
        didSet {
            delegate?.didTrackingChange(isTrackingActive)
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
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func startUpdatingLocation() {
        if authorizationStatus != .authorizedWhenInUse &&
           authorizationStatus != .authorizedAlways {
            // Request permission if not authorized
            requestAlwaysPermission()
        }
        
        isTrackingActive = true
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        isTrackingActive = false
        locationManager.stopUpdatingLocation()
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
            // Konumlar kaydedilirken adres bilgisi eklenmez
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
            statusText = "Location permission granted"
        case .denied:
            statusText = "Location permission denied"
        case .restricted:
            statusText = "Location access is restricted"
        case .notDetermined:
            statusText = "Waiting for permission..."
        @unknown default:
            statusText = "Unknown authorization status"
        }
        delegate?.didChangeAuthorizationStatus(statusText: statusText)
    }
    
    func didFailWithError(_ error: Error) {
        delegate?.didFailWithError(error)
    }
}
