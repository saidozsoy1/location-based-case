//
//  CoreDataManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

import Foundation
import CoreData
import CoreLocation

protocol CoreDataManaging: StoreDataManaging {
    func saveRoutePoints(_ routePoints: [RoutePoint]) throws
    func loadRoutePoints() -> [RoutePoint]?
    func deleteAllRoutePoints()
    func saveContext() throws
}

class CoreDataManager: CoreDataManaging {
    // MARK: - Core Data Stack
    private let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    init(persistentContainerName: String = "RoutePoint") {
        self.persistentContainer = NSPersistentContainer(name: persistentContainerName)
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    func saveRoutePoints(_ routePoints: [RoutePoint]) throws {
        // Clear existing route points
        deleteAllRoutePoints()
        
        // Create new entities
        for point in routePoints {
            let entity = RoutePointEntity(context: context)
            entity.latitude = point.latitude
            entity.longitude = point.longitude
            entity.timestamp = point.timestamp
        }
        
        try saveContext()
    }
    
    func loadRoutePoints() -> [RoutePoint]? {
        let fetchRequest: NSFetchRequest<RoutePointEntity> = RoutePointEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let routePointEntities = try context.fetch(fetchRequest)
            if routePointEntities.isEmpty {
                return nil
            }
            
            return routePointEntities.map { entity in
                let latitude = entity.latitude
                let longitude = entity.longitude
                let timestamp = entity.timestamp
                
                return RoutePoint(latitude: latitude, longitude: longitude, timestamp: timestamp)
            }
        } catch {
            print("Error fetching route points: \(error)")
            return nil
        }
    }
    
    func deleteAllRoutePoints() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RoutePointEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try saveContext()
        } catch {
            print("Error deleting route points: \(error)")
        }
    }
    
    // MARK: - Core Data Saving support
    func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
        }
    }
}

// Extension to conform to StoreDataManaging protocol
extension CoreDataManager: StoreDataManaging {
    func saveObject<T: Encodable>(_ object: T, forKey key: StoreKey) throws {
        if key == .routePoints, let routePoints = object as? [RoutePoint] {
            try saveRoutePoints(routePoints)
        }
    }
    
    func loadObject<T: Decodable>(forKey key: StoreKey, as type: T.Type) throws -> T? {
        if key == .routePoints, type == [RoutePoint].self {
            if let routePoints = loadRoutePoints() {
                return routePoints as? T
            }
            return nil
        }
        return nil
    }
    
    func removeObject(forKey key: StoreKey) {
        switch key {
        case .routePoints:
            deleteAllRoutePoints()
        }
    }
} 
