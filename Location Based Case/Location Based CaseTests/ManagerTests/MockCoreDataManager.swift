import Foundation
import CoreData
import CoreLocation
@testable import Location_Based_Case

class MockCoreDataManager: CoreDataManaging {
    // Counters to track test calls
    var saveRoutePointsCallCount = 0
    var loadRoutePointsCallCount = 0
    var deleteAllRoutePointsCallCount = 0
    var saveContextCallCount = 0
    var saveObjectCallCount = 0
    var loadObjectCallCount = 0
    var removeObjectCallCount = 0
    
    // Return values for testing
    var mockRoutePoints: [RoutePoint]?
    var shouldThrowOnSaveRoutePoints = false
    var shouldThrowOnSaveContext = false
    var shouldThrowOnSaveObject = false
    var shouldThrowOnLoadObject = false
    
    // Core Data operations
    func saveRoutePoints(_ routePoints: [RoutePoint]) throws {
        saveRoutePointsCallCount += 1
        
        if shouldThrowOnSaveRoutePoints {
            throw CoreDataError.saveFailed
        }
        
        mockRoutePoints = routePoints
    }
    
    func loadRoutePoints() -> [RoutePoint]? {
        loadRoutePointsCallCount += 1
        return mockRoutePoints
    }
    
    func deleteAllRoutePoints() {
        deleteAllRoutePointsCallCount += 1
        mockRoutePoints = nil
    }
    
    func saveContext() throws {
        saveContextCallCount += 1
        
        if shouldThrowOnSaveContext {
            throw CoreDataError.saveFailed
        }
    }
    
    // StoreDataManaging protocol
    func saveObject<T: Encodable>(_ object: T, forKey key: StoreKey) throws {
        saveObjectCallCount += 1
        
        if shouldThrowOnSaveObject {
            throw StoreDataError.encodingFailed
        }
        
        if key == .routePoints, let routePoints = object as? [RoutePoint] {
            try saveRoutePoints(routePoints)
        }
    }
    
    func loadObject<T: Decodable>(forKey key: StoreKey, as type: T.Type) throws -> T? {
        loadObjectCallCount += 1
        
        if shouldThrowOnLoadObject {
            throw StoreDataError.decodingFailed
        }
        
        if key == .routePoints, type == [RoutePoint].self {
            if let routePoints = loadRoutePoints() {
                return routePoints as? T
            }
            return nil
        }
        return nil
    }
    
    func removeObject(forKey key: StoreKey) {
        removeObjectCallCount += 1
        
        switch key {
        case .routePoints:
            deleteAllRoutePoints()
        }
    }
    
    // Helper method for testing
    func reset() {
        saveRoutePointsCallCount = 0
        loadRoutePointsCallCount = 0
        deleteAllRoutePointsCallCount = 0
        saveContextCallCount = 0
        saveObjectCallCount = 0
        loadObjectCallCount = 0
        removeObjectCallCount = 0
        
        mockRoutePoints = nil
        shouldThrowOnSaveRoutePoints = false
        shouldThrowOnSaveContext = false
        shouldThrowOnSaveObject = false
        shouldThrowOnLoadObject = false
    }
}

// Error types for Core Data
enum CoreDataError: Error {
    case saveFailed
    case fetchFailed
    case deleteFailed
} 