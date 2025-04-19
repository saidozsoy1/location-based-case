//
//  RouteAnnotation.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import Foundation
import MapKit

class RouteAnnotation: MKPointAnnotation {
    var index: Int = 0
    
    init(coordinate: CLLocationCoordinate2D, index: Int = 0) {
        self.index = index
        super.init()
        self.coordinate = coordinate
        self.title = "Location Point \(index)"
        self.subtitle = String(format: "Lat: %.5f, Lng: %.5f", coordinate.latitude, coordinate.longitude)
    }
} 
