//
//  DataManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import Foundation
import CoreLocation

protocol DataManaging {
    func saveRoutePoints(_ routePoints: [RoutePoint]) throws
    func loadRoutePoints() throws -> [RoutePoint]?
    func clearRoutePoints()
    
    func convertToLocations(_ routePoints: [RoutePoint]) -> [CLLocation]
    func convertToRoutePoints(_ locations: [CLLocation]) -> [RoutePoint]
}

class DataManager: DataManaging {
    private let storeManager: StoreDataManaging
    
    init(storeManager: StoreDataManaging = StoreDataManager()) {
        self.storeManager = storeManager
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
} 