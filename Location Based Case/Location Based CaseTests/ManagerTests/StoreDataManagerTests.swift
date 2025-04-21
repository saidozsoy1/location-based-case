import XCTest
@testable import Location_Based_Case

class StoreDataManagerTests: XCTestCase {
    
    var sut: StoreDataManager!
    var mockUserDefaults: UserDefaultsMock!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaultsMock()
        sut = StoreDataManager(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        sut = nil
        mockUserDefaults = nil
        super.tearDown()
    }
    
    func testSaveObject() throws {
        // Given
        let testObject = TestObject(id: 1, name: "Test")
        
        // When
        try sut.saveObject(testObject, forKey: .routePoints)
        
        // Then
        XCTAssertTrue(mockUserDefaults.setDataCalled)
        XCTAssertEqual(mockUserDefaults.lastSetKey, StoreKey.routePoints.key)
        XCTAssertNotNil(mockUserDefaults.lastSetData)
    }
    
    func testLoadObject() throws {
        // Given
        let testObject = TestObject(id: 1, name: "Test")
        let testData = try JSONEncoder().encode(testObject)
        mockUserDefaults.dataToReturn = testData
        
        // When
        let loadedObject = try sut.loadObject(forKey: .routePoints, as: TestObject.self)
        
        // Then
        XCTAssertTrue(mockUserDefaults.dataForKeyCalled)
        XCTAssertEqual(mockUserDefaults.lastDataKey, StoreKey.routePoints.key)
        XCTAssertNotNil(loadedObject)
        XCTAssertEqual(loadedObject?.id, 1)
        XCTAssertEqual(loadedObject?.name, "Test")
    }
    
    func testLoadObjectReturnsNilWhenNoData() throws {
        // Given
        mockUserDefaults.dataToReturn = nil
        
        // When
        let loadedObject = try sut.loadObject(forKey: .routePoints, as: TestObject.self)
        
        // Then
        XCTAssertTrue(mockUserDefaults.dataForKeyCalled)
        XCTAssertEqual(mockUserDefaults.lastDataKey, StoreKey.routePoints.key)
        XCTAssertNil(loadedObject)
    }
    
    func testLoadObjectThrowsWhenDecodingFails() {
        // Given
        mockUserDefaults.dataToReturn = "Invalid JSON".data(using: .utf8)
        
        // When/Then
        XCTAssertThrowsError(try sut.loadObject(forKey: .routePoints, as: TestObject.self)) { error in
            XCTAssertEqual(error as? StoreDataError, StoreDataError.decodingFailed)
        }
    }
    
    func testRemoveObject() {
        // Given
        let key = StoreKey.routePoints
        
        // When
        sut.removeObject(forKey: key)
        
        // Then
        XCTAssertTrue(mockUserDefaults.removeObjectCalled)
        XCTAssertEqual(mockUserDefaults.lastRemovedKey, key.key)
    }
}

// Helper classes for testing
class UserDefaultsMock: UserDefaults {
    var setDataCalled = false
    var dataForKeyCalled = false
    var removeObjectCalled = false
    
    var lastSetData: Data?
    var lastSetKey: String?
    var lastDataKey: String?
    var lastRemovedKey: String?
    
    var dataToReturn: Data?
    
    override func set(_ value: Any?, forKey key: String) {
        if let data = value as? Data {
            setDataCalled = true
            lastSetData = data
            lastSetKey = key
        }
    }
    
    override func data(forKey key: String) -> Data? {
        dataForKeyCalled = true
        lastDataKey = key
        return dataToReturn
    }
    
    override func removeObject(forKey key: String) {
        removeObjectCalled = true
        lastRemovedKey = key
    }
}

// Test model for serialization
struct TestObject: Codable, Equatable {
    let id: Int
    let name: String
} 