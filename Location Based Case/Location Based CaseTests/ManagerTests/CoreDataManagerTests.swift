import XCTest
import CoreLocation
import CoreData
@testable import Location_Based_Case

class CoreDataManagerTests: XCTestCase {
    
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUp() {
        super.setUp()
        mockCoreDataManager = MockCoreDataManager()
    }
    
    override func tearDown() {
        mockCoreDataManager = nil
        super.tearDown()
    }
    
    func testSaveRoutePoints() throws {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970),
            RoutePoint(latitude: 41.0102, longitude: 28.9802, timestamp: Date().timeIntervalSince1970)
        ]
        
        // When
        try mockCoreDataManager.saveRoutePoints(routePoints)
        
        // Then
        XCTAssertEqual(mockCoreDataManager.saveRoutePointsCallCount, 1)
        XCTAssertEqual(mockCoreDataManager.mockRoutePoints?.count, 2)
        XCTAssertEqual(mockCoreDataManager.mockRoutePoints?.first?.latitude, 41.0082)
    }
    
    func testSaveRoutePointsThrowsError() {
        // Given
        let routePoints = [RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)]
        mockCoreDataManager.shouldThrowOnSaveRoutePoints = true
        
        // When, Then
        XCTAssertThrowsError(try mockCoreDataManager.saveRoutePoints(routePoints)) { error in
            XCTAssertEqual(error as? CoreDataError, CoreDataError.saveFailed)
        }
        XCTAssertEqual(mockCoreDataManager.saveRoutePointsCallCount, 1)
    }
    
    func testLoadRoutePoints() throws {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970),
            RoutePoint(latitude: 41.0102, longitude: 28.9802, timestamp: Date().timeIntervalSince1970)
        ]
        mockCoreDataManager.mockRoutePoints = routePoints
        
        // When
        let loadedRoutePoints = mockCoreDataManager.loadRoutePoints()
        
        // Then
        XCTAssertEqual(mockCoreDataManager.loadRoutePointsCallCount, 1)
        XCTAssertEqual(loadedRoutePoints?.count, 2)
        XCTAssertEqual(loadedRoutePoints?.first?.latitude, 41.0082)
    }
    
    func testDeleteAllRoutePoints() {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)
        ]
        mockCoreDataManager.mockRoutePoints = routePoints
        
        // When
        mockCoreDataManager.deleteAllRoutePoints()
        
        // Then
        XCTAssertEqual(mockCoreDataManager.deleteAllRoutePointsCallCount, 1)
        XCTAssertNil(mockCoreDataManager.mockRoutePoints)
        
        // Verify by loading
        let loadedPoints = mockCoreDataManager.loadRoutePoints()
        XCTAssertNil(loadedPoints)
    }
    
    func testSaveContext() throws {
        // When
        try mockCoreDataManager.saveContext()
        
        // Then
        XCTAssertEqual(mockCoreDataManager.saveContextCallCount, 1)
    }
    
    func testSaveContextThrowsError() {
        // Given
        mockCoreDataManager.shouldThrowOnSaveContext = true
        
        // When, Then
        XCTAssertThrowsError(try mockCoreDataManager.saveContext()) { error in
            XCTAssertEqual(error as? CoreDataError, CoreDataError.saveFailed)
        }
        XCTAssertEqual(mockCoreDataManager.saveContextCallCount, 1)
    }
    
    // MARK: - StoreDataManaging Tests
    
    func testSaveObject() throws {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)
        ]
        
        // When
        try mockCoreDataManager.saveObject(routePoints, forKey: .routePoints)
        
        // Then
        XCTAssertEqual(mockCoreDataManager.saveObjectCallCount, 1)
        XCTAssertEqual(mockCoreDataManager.saveRoutePointsCallCount, 1)
        XCTAssertEqual(mockCoreDataManager.mockRoutePoints?.count, 1)
    }
    
    func testSaveObjectThrowsError() {
        // Given
        let routePoints = [RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)]
        mockCoreDataManager.shouldThrowOnSaveObject = true
        
        // When, Then
        XCTAssertThrowsError(try mockCoreDataManager.saveObject(routePoints, forKey: .routePoints)) { error in
            XCTAssertEqual(error as? StoreDataError, StoreDataError.encodingFailed)
        }
        XCTAssertEqual(mockCoreDataManager.saveObjectCallCount, 1)
        XCTAssertEqual(mockCoreDataManager.saveRoutePointsCallCount, 0) // Shouldn't call saveRoutePoints due to early return
    }
    
    func testLoadObject() throws {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)
        ]
        mockCoreDataManager.mockRoutePoints = routePoints
        
        // When
        let loadedPoints = try mockCoreDataManager.loadObject(forKey: .routePoints, as: [RoutePoint].self)
        
        // Then
        XCTAssertEqual(mockCoreDataManager.loadObjectCallCount, 1)
        XCTAssertEqual(mockCoreDataManager.loadRoutePointsCallCount, 1)
        XCTAssertEqual(loadedPoints?.count, 1)
        XCTAssertEqual(loadedPoints?.first?.latitude, 41.0082)
    }
    
    func testLoadObjectThrowsError() {
        // Given
        mockCoreDataManager.shouldThrowOnLoadObject = true
        
        // When, Then
        XCTAssertThrowsError(try mockCoreDataManager.loadObject(forKey: .routePoints, as: [RoutePoint].self)) { error in
            XCTAssertEqual(error as? StoreDataError, StoreDataError.decodingFailed)
        }
        XCTAssertEqual(mockCoreDataManager.loadObjectCallCount, 1)
        XCTAssertEqual(mockCoreDataManager.loadRoutePointsCallCount, 0) // Shouldn't call loadRoutePoints due to early return
    }
    
    func testRemoveObject() {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)
        ]
        mockCoreDataManager.mockRoutePoints = routePoints
        
        // When
        mockCoreDataManager.removeObject(forKey: .routePoints)
        
        // Then
        XCTAssertEqual(mockCoreDataManager.removeObjectCallCount, 1)
        XCTAssertEqual(mockCoreDataManager.deleteAllRoutePointsCallCount, 1)
        XCTAssertNil(mockCoreDataManager.mockRoutePoints)
    }
    
    func testReset() throws {
        // Given
        let routePoints = [RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)]
        try mockCoreDataManager.saveRoutePoints(routePoints)
        mockCoreDataManager.loadRoutePoints()
        mockCoreDataManager.deleteAllRoutePoints()
        try mockCoreDataManager.saveContext()
        mockCoreDataManager.shouldThrowOnSaveContext = true
        
        // When
        mockCoreDataManager.reset()
        
        // Then
        XCTAssertEqual(mockCoreDataManager.saveRoutePointsCallCount, 0)
        XCTAssertEqual(mockCoreDataManager.loadRoutePointsCallCount, 0)
        XCTAssertEqual(mockCoreDataManager.deleteAllRoutePointsCallCount, 0)
        XCTAssertEqual(mockCoreDataManager.saveContextCallCount, 0)
        XCTAssertNil(mockCoreDataManager.mockRoutePoints)
        XCTAssertFalse(mockCoreDataManager.shouldThrowOnSaveContext)
    }
} 
