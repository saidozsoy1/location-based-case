//
//  RoutePoint.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import Foundation
import CoreLocation

struct RoutePoint: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Double
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = location.timestamp.timeIntervalSince1970
    }
    
    // Initializer for creating from CoreData entity
    init(latitude: Double, longitude: Double, timestamp: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
    
    func toLocation() -> CLLocation {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let date = Date(timeIntervalSince1970: timestamp)
        return CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: date)
    }
}
