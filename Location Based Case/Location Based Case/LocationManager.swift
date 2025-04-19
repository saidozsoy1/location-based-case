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
    func startUpdatingLocation()
    func stopUpdatingLocation()
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
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
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
