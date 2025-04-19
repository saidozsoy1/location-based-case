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
}

final class MainViewModel {
    private var locationManager: LocationManaging
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
    private let routePointsKey = "savedRoutePoints"
    
    init(locationManager: LocationManaging) {
        self.locationManager = locationManager
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
        UserDefaults.standard.removeObject(forKey: routePointsKey)
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
        let routeData = routePoints.map { RoutePoint(location: $0) }
        
        do {
            let data = try JSONEncoder().encode(routeData)
            UserDefaults.standard.set(data, forKey: routePointsKey)
        } catch {
            print("Error encoding route data: \(error)")
        }
    }
    
    func loadSavedRoute() {
        guard let data = UserDefaults.standard.data(forKey: routePointsKey) else {
            return
        }
        
        do {
            let routeData = try JSONDecoder().decode([RoutePoint].self, from: data)
            let locations = routeData.map { $0.toLocation() }
            routePoints = locations
            delegate?.didLoadSavedRoute(locations)
        } catch {
            print("Error decoding route data: \(error)")
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
