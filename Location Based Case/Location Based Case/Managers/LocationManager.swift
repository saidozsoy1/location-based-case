//
//  LocationManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import Foundation
import CoreLocation

protocol LocationManaging {
    var authorizationStatus: CLAuthorizationStatus { get }
    var lastLocation: CLLocation? { get }
    var delegate: LocationManagerDelegate? { get set }
    
    func getCurrentLocation() -> CLLocation?
    func requestLocation()
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation(shouldContinueInTheBackground: Bool)
    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()
}

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocations(_ locations: [CLLocation])
    func didChangeAuthorizationStatus(_ status: CLAuthorizationStatus)
    func didFailWithError(_ error: Error)
}

final class LocationManager: NSObject, LocationManaging {
    private let locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    
    private(set) var lastLocation: CLLocation?
    
    var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getCurrentLocation() -> CLLocation? {
        return locationManager.location
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation(shouldContinueInTheBackground: Bool) {
        locationManager.stopUpdatingLocation()
        if (!shouldContinueInTheBackground) {
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.pausesLocationUpdatesAutomatically = true
        }
    }
    
    func startMonitoringSignificantLocationChanges() {
        // if we'd like to decrease battery usage but get less frequent updates ie. every 500 meters
//        stopUpdatingLocation(shouldContinueInTheBackground: true)
        
        // Just to be safe in background also use significantLocationChanges
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        delegate?.didUpdateLocations(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.didChangeAuthorizationStatus(status)
    }
}
