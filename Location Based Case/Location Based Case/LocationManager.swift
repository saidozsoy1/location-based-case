//
//  LocationManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import Foundation
import CoreLocation

protocol LocationManaging {
    func getCurrentLocation() -> CLLocation?
    func requestLocation()
}

final class LocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() -> CLLocation? {
        return locationManager.location
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
}
