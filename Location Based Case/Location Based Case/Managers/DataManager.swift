//
//  DataManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import Foundation
import CoreLocation
import MapKit

protocol DataManaging {
    func saveRoutePoints(_ routePoints: [RoutePoint]) throws
    func loadRoutePoints() throws -> [RoutePoint]?
    func clearRoutePoints()
    
    func convertToLocations(_ routePoints: [RoutePoint]) -> [CLLocation]
    func convertToRoutePoints(_ locations: [CLLocation]) -> [RoutePoint]
    
    func getAddressFromLocation(_ location: CLLocation, completion: @escaping (String?, Error?) -> Void)
}

class DataManager: DataManaging {
    private let storeManager: StoreDataManaging
    private let geocoder: CLGeocoder
    
    init(storeManager: StoreDataManaging, geocoder: CLGeocoder = CLGeocoder()) {
        self.storeManager = storeManager
        self.geocoder = geocoder
    }
    
    func saveRoutePoints(_ routePoints: [RoutePoint]) throws {
        try storeManager.saveObject(routePoints, forKey: .routePoints)
    }
    
    func loadRoutePoints() throws -> [RoutePoint]? {
        return try storeManager.loadObject(forKey: .routePoints, as: [RoutePoint].self)
    }
    
    func clearRoutePoints() {
        storeManager.removeObject(forKey: .routePoints)
    }
    
    func convertToLocations(_ routePoints: [RoutePoint]) -> [CLLocation] {
        return routePoints.map { $0.toLocation() }
    }
    
    func convertToRoutePoints(_ locations: [CLLocation]) -> [RoutePoint] {
        return locations.map { RoutePoint(location: $0) }
    }
    
    // MARK: - Geocoding Implementation
    
    func getAddressFromLocation(_ location: CLLocation, completion: @escaping (String?, Error?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(nil, NSError(domain: "DataManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No address found"]))
                return
            }
            
            // Format address from placemark
            let address = self?.formatAddress(from: placemark)
            completion(address, nil)
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        if let postalCode = placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
} 
