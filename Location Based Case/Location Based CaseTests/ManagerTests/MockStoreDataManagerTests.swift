import XCTest
@testable import Location_Based_Case

class MockStoreDataManagerTests: XCTestCase {
    
    var mockStoreManager: MockStoreDataManager!
    
    override func setUp() {
        super.setUp()
        mockStoreManager = MockStoreDataManager()
    }
    
    override func tearDown() {
        mockStoreManager = nil
        super.tearDown()
    }
    
    func testSaveObject() throws {
        // Given
        let testObject = TestObject(id: 1, name: "Test")
        
        // When
        try mockStoreManager.saveObject(testObject, forKey: .routePoints)
        
        // Then
        XCTAssertEqual(mockStoreManager.saveObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastSavedKey, .routePoints)
        
        // Verify we can load back the object
        let loadedObject = try mockStoreManager.loadObject(forKey: .routePoints, as: TestObject.self)
        XCTAssertEqual(loadedObject?.id, 1)
        XCTAssertEqual(loadedObject?.name, "Test")
    }
    
    func testSaveObjectThrowsWhenConfigured() {
        // Given
        let testObject = TestObject(id: 1, name: "Test")
        mockStoreManager.shouldThrowOnSave = true
        
        // When/Then
        XCTAssertThrowsError(try mockStoreManager.saveObject(testObject, forKey: .routePoints)) { error in
            XCTAssertEqual(error as? StoreDataError, StoreDataError.encodingFailed)
        }
        XCTAssertEqual(mockStoreManager.saveObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastSavedKey, .routePoints)
    }
    
    func testLoadObject() throws {
        // Given
        let testObject = TestObject(id: 1, name: "Test")
        try mockStoreManager.saveObject(testObject, forKey: .routePoints)

        // Reset counters but keep stored data by using resetCounters
        mockStoreManager.resetCounters()
        
        // When
        let loadedObject = try mockStoreManager.loadObject(forKey: .routePoints, as: TestObject.self)
        
        // Then
        XCTAssertEqual(mockStoreManager.loadObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastLoadedKey, .routePoints)
        XCTAssertNotNil(loadedObject)
        XCTAssertEqual(loadedObject?.id, 1)
        XCTAssertEqual(loadedObject?.name, "Test")
    }
    
    func testLoadObjectReturnsNilWhenNoData() throws {
        // Given
        // No data saved
        
        // When
        let loadedObject = try mockStoreManager.loadObject(forKey: .routePoints, as: TestObject.self)
        
        // Then
        XCTAssertEqual(mockStoreManager.loadObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastLoadedKey, .routePoints)
        XCTAssertNil(loadedObject)
    }
    
    func testLoadObjectThrowsWhenConfigured() {
        // Given
        mockStoreManager.shouldThrowOnLoad = true
        
        // When/Then
        XCTAssertThrowsError(try mockStoreManager.loadObject(forKey: .routePoints, as: TestObject.self)) { error in
            XCTAssertEqual(error as? StoreDataError, StoreDataError.decodingFailed)
        }
        XCTAssertEqual(mockStoreManager.loadObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastLoadedKey, .routePoints)
    }
    
    func testRemoveObject() throws {
        // Given
        let testObject = TestObject(id: 1, name: "Test")
        try mockStoreManager.saveObject(testObject, forKey: .routePoints)
        
        // When
        mockStoreManager.removeObject(forKey: .routePoints)
        
        // Then
        XCTAssertEqual(mockStoreManager.removeObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastRemovedKey, .routePoints)
        
        // Verify object was removed
        let loadedObject = try mockStoreManager.loadObject(forKey: .routePoints, as: TestObject.self)
        XCTAssertNil(loadedObject)
    }
    
    func testReset() throws {
        // Given
        let testObject = TestObject(id: 1, name: "Test")
        try mockStoreManager.saveObject(testObject, forKey: .routePoints)
        mockStoreManager.removeObject(forKey: .routePoints)
        
        // When
        mockStoreManager.reset()
        
        // Then
        XCTAssertEqual(mockStoreManager.saveObjectCallCount, 0)
        XCTAssertEqual(mockStoreManager.loadObjectCallCount, 0)
        XCTAssertEqual(mockStoreManager.removeObjectCallCount, 0)
        XCTAssertNil(mockStoreManager.lastSavedKey)
        XCTAssertNil(mockStoreManager.lastLoadedKey)
        XCTAssertNil(mockStoreManager.lastRemovedKey)
        
        // Storage should be empty after reset
        XCTAssertNil(try mockStoreManager.loadObject(forKey: .routePoints, as: TestObject.self))
    }
} 