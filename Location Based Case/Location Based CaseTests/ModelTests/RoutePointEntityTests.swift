import XCTest
import CoreData
import CoreLocation
@testable import Location_Based_Case

class RoutePointEntityTests: XCTestCase {
    
    // In-memory Core Data stack for testing
    private var container: NSPersistentContainer!
    private var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        setupInMemoryCoreDataStack()
    }
    
    override func tearDown() {
        context = nil
        container = nil
        super.tearDown()
    }
    
    private func setupInMemoryCoreDataStack() {
        container = NSPersistentContainer(name: "RoutePoint")
        
        // Configure for in-memory storage
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (description, error) in
            if let error = error {
                XCTFail("Failed to load in-memory persistent store: \(error.localizedDescription)")
                return
            }
        }
        
        context = container.viewContext
    }
    
    func testCreateRoutePointEntity() {
        // Given
        let latitude = 41.0082
        let longitude = 28.9784
        let timestamp = Date().timeIntervalSince1970
        
        // When
        let routePointEntity = RoutePointEntity(context: context)
        routePointEntity.latitude = latitude
        routePointEntity.longitude = longitude
        routePointEntity.timestamp = timestamp
        
        // Then
        XCTAssertEqual(routePointEntity.latitude, latitude)
        XCTAssertEqual(routePointEntity.longitude, longitude)
        XCTAssertEqual(routePointEntity.timestamp, timestamp)
    }
    
    func testFetchRoutePointEntity() throws {
        // Given
        let latitude = 41.0082
        let longitude = 28.9784
        let timestamp = Date().timeIntervalSince1970
        
        let routePointEntity = RoutePointEntity(context: context)
        routePointEntity.latitude = latitude
        routePointEntity.longitude = longitude
        routePointEntity.timestamp = timestamp
        
        try context.save()
        
        // When
        let fetchRequest: NSFetchRequest<RoutePointEntity> = RoutePointEntity.fetchRequest()
        let fetchedResults = try context.fetch(fetchRequest)
        
        // Then
        XCTAssertEqual(fetchedResults.count, 1)
        let fetchedEntity = fetchedResults.first
        XCTAssertEqual(fetchedEntity?.latitude, latitude)
        XCTAssertEqual(fetchedEntity?.longitude, longitude)
        XCTAssertEqual(fetchedEntity?.timestamp, timestamp)
    }
    
    func testDeleteRoutePointEntity() throws {
        // Given
        let routePointEntity = RoutePointEntity(context: context)
        routePointEntity.latitude = 41.0082
        routePointEntity.longitude = 28.9784
        routePointEntity.timestamp = Date().timeIntervalSince1970
        
        try context.save()
        
        // Verify it was saved
        let fetchRequest: NSFetchRequest<RoutePointEntity> = RoutePointEntity.fetchRequest()
        var fetchedResults = try context.fetch(fetchRequest)
        XCTAssertEqual(fetchedResults.count, 1)
        
        // When
        context.delete(routePointEntity)
        try context.save()
        
        // Then
        fetchedResults = try context.fetch(fetchRequest)
        XCTAssertEqual(fetchedResults.count, 0)
    }
    
    func testConversionToRoutePoint() throws {
        // Given
        let latitude = 41.0082
        let longitude = 28.9784
        let timestamp = Date().timeIntervalSince1970
        
        let routePointEntity = RoutePointEntity(context: context)
        routePointEntity.latitude = latitude
        routePointEntity.longitude = longitude
        routePointEntity.timestamp = timestamp
        
        // When
        let routePoint = RoutePoint(latitude: routePointEntity.latitude,
                                    longitude: routePointEntity.longitude,
                                    timestamp: routePointEntity.timestamp)
        
        // Then
        XCTAssertEqual(routePoint.latitude, latitude)
        XCTAssertEqual(routePoint.longitude, longitude)
        XCTAssertEqual(routePoint.timestamp, timestamp)
    }
    
    func testMultipleRoutePointEntities() throws {
        // Given
        let points = [
            (latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970),
            (latitude: 41.0090, longitude: 28.9790, timestamp: Date().timeIntervalSince1970 + 60),
            (latitude: 41.0100, longitude: 28.9800, timestamp: Date().timeIntervalSince1970 + 120)
        ]
        
        // When - Create multiple entities
        for point in points {
            let entity = RoutePointEntity(context: context)
            entity.latitude = point.latitude
            entity.longitude = point.longitude
            entity.timestamp = point.timestamp
        }
        
        try context.save()
        
        // Then - Fetch and verify
        let fetchRequest: NSFetchRequest<RoutePointEntity> = RoutePointEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResults = try context.fetch(fetchRequest)
        XCTAssertEqual(fetchedResults.count, 3)
        
        // Verify they're in the correct order (sorted by timestamp)
        XCTAssertEqual(fetchedResults[0].latitude, points[0].latitude)
        XCTAssertEqual(fetchedResults[1].latitude, points[1].latitude)
        XCTAssertEqual(fetchedResults[2].latitude, points[2].latitude)
    }
    
    func testBulkDeleteRoutePointEntities() throws {
        // Given
        for i in 0..<5 {
            let entity = RoutePointEntity(context: context)
            entity.latitude = 41.0 + Double(i) * 0.001
            entity.longitude = 28.9 + Double(i) * 0.001
            entity.timestamp = Date().timeIntervalSince1970 + Double(i) * 60
        }
        
        try context.save()
        
        // Verify they were saved
        let fetchRequest: NSFetchRequest<RoutePointEntity> = RoutePointEntity.fetchRequest()
        var fetchedResults = try context.fetch(fetchRequest)
        XCTAssertEqual(fetchedResults.count, 5)
        
        // When - Delete all entities one by one (in-memory store doesn't support batch delete)
        for entity in fetchedResults {
            context.delete(entity)
        }
        try context.save()
        
        // Then
        fetchedResults = try context.fetch(fetchRequest)
        XCTAssertEqual(fetchedResults.count, 0)
    }
} 