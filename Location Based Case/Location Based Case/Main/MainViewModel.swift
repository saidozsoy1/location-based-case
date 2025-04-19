//
//  MainViewModel.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import Foundation
import CoreLocation

protocol MainViewModelDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
    func didChangeAuthorizationStatus(_ status: CLAuthorizationStatus)
    func didFailWithError(_ error: Error)
}

final class MainViewModel {
    private var locationManager: LocationManaging
    weak var delegate: MainViewModelDelegate?
    
    var currentLocation: CLLocation? {
        return locationManager.lastLocation
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }

    init(locationManager: LocationManaging) {
        self.locationManager = locationManager
        self.locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func startUpdatingLocation() {
        if authorizationStatus != .authorizedWhenInUse &&
           authorizationStatus != .authorizedAlways {
            // Request permission if not authorized
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension MainViewModel: LocationManagerDelegate {
    func didUpdateLocations(_ locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocation(location)
    }
    
    func didChangeAuthorizationStatus(_ status: CLAuthorizationStatus) {
        delegate?.didChangeAuthorizationStatus(status)
        
        // If authorized, request location immediately
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            requestLocation()
        }
    }
    
    func didFailWithError(_ error: Error) {
        delegate?.didFailWithError(error)
    }
}
