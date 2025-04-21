import XCTest
import CoreLocation
@testable import Location_Based_Case

class DataManagerTests: XCTestCase {
    
    var sut: DataManager!
    var mockStoreManager: MockStoreDataManager!
    var mockGeocoder: MockCLGeocoder!
    
    override func setUp() {
        super.setUp()
        mockStoreManager = MockStoreDataManager()
        mockGeocoder = MockCLGeocoder()
        sut = DataManager(storeManager: mockStoreManager, geocoder: mockGeocoder)
    }
    
    override func tearDown() {
        sut = nil
        mockStoreManager = nil
        mockGeocoder = nil
        super.tearDown()
    }
    
    func testSaveRoutePoints() throws {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date()),
            RoutePoint(latitude: 41.0102, longitude: 28.9802, timestamp: Date())
        ]
        
        // When
        try sut.saveRoutePoints(routePoints)
        
        // Then
        XCTAssertEqual(mockStoreManager.saveObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastSavedKey, .routePoints)
    }
    
    func testLoadRoutePoints() throws {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date()),
            RoutePoint(latitude: 41.0102, longitude: 28.9802, timestamp: Date())
        ]
        try mockStoreManager.saveObject(routePoints, forKey: .routePoints)
        
        // When
        let loadedRoutePoints = try sut.loadRoutePoints()
        
        // Then
        XCTAssertEqual(mockStoreManager.loadObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastLoadedKey, .routePoints)
        XCTAssertNotNil(loadedRoutePoints)
        XCTAssertEqual(loadedRoutePoints?.count, 2)
    }
    
    func testClearRoutePoints() {
        // Given
        // Save something to test the clearing process
        
        // When
        sut.clearRoutePoints()
        
        // Then
        XCTAssertEqual(mockStoreManager.removeObjectCallCount, 1)
        XCTAssertEqual(mockStoreManager.lastRemovedKey, .routePoints)
    }
    
    func testConvertToLocations() {
        // Given
        let now = Date()
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: now),
            RoutePoint(latitude: 41.0102, longitude: 28.9802, timestamp: now)
        ]
        
        // When
        let locations = sut.convertToLocations(routePoints)
        
        // Then
        XCTAssertEqual(locations.count, 2)
        XCTAssertEqual(locations[0].coordinate.latitude, 41.0082)
        XCTAssertEqual(locations[0].coordinate.longitude, 28.9784)
        XCTAssertEqual(locations[1].coordinate.latitude, 41.0102)
        XCTAssertEqual(locations[1].coordinate.longitude, 28.9802)
    }
    
    func testConvertToRoutePoints() {
        // Given
        let now = Date()
        let locations = [
            CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: now),
            CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.0102, longitude: 28.9802), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: now)
        ]
        
        // When
        let routePoints = sut.convertToRoutePoints(locations)
        
        // Then
        XCTAssertEqual(routePoints.count, 2)
        XCTAssertEqual(routePoints[0].latitude, 41.0082)
        XCTAssertEqual(routePoints[0].longitude, 28.9784)
        XCTAssertEqual(routePoints[1].latitude, 41.0102)
        XCTAssertEqual(routePoints[1].longitude, 28.9802)
    }
    
    func testGetAddressFromLocation() {
        // Given
        let location = CLLocation(latitude: 41.0082, longitude: 28.9784)
        let expectedAddress = "Istanbul, Turkey"
        
        mockGeocoder.mockPlacemark = MockCLPlacemark(
            thoroughfare: "Istiklal Caddesi",
            subThoroughfare: "123",
            locality: "Istanbul",
            subLocality: "Beyoglu",
            administrativeArea: "Marmara",
            postalCode: "34000",
            country: "Turkey"
        )
        
        // When
        var addressResult: String?
        var errorResult: Error?
        
        let expectation = self.expectation(description: "Geocoding")
        
        sut.getAddressFromLocation(location) { address, error in
            addressResult = address
            errorResult = error
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(addressResult)
        XCTAssertNil(errorResult)
        XCTAssertTrue(addressResult!.contains("Istanbul"))
        XCTAssertTrue(addressResult!.contains("Turkey"))
    }
    
    func testGetAddressFromLocationError() {
        // Given
        let location = CLLocation(latitude: 41.0082, longitude: 28.9784)
        let expectedError = NSError(domain: "GeocodingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Geocoding failed"])
        
        mockGeocoder.shouldReturnError = true
        mockGeocoder.errorToReturn = expectedError
        
        // When
        var addressResult: String?
        var errorResult: Error?
        
        let expectation = self.expectation(description: "Geocoding Error")
        
        sut.getAddressFromLocation(location) { address, error in
            addressResult = address
            errorResult = error
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNil(addressResult)
        XCTAssertNotNil(errorResult)
        XCTAssertEqual((errorResult as NSError?)?.domain, "GeocodingError")
    }
    
    func testGetAddressFromLocationNoPlacemarks() {
        // Given
        let location = CLLocation(latitude: 41.0082, longitude: 28.9784)
        
        mockGeocoder.shouldReturnEmptyPlacemarks = true
        
        // When
        var addressResult: String?
        var errorResult: Error?
        
        let expectation = self.expectation(description: "Geocoding No Placemarks")
        
        sut.getAddressFromLocation(location) { address, error in
            addressResult = address
            errorResult = error
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNil(addressResult)
        XCTAssertNotNil(errorResult)
        XCTAssertEqual((errorResult as NSError?)?.domain, "DataManagerError")
    }
}

// MARK: - Mock Classes

class MockCLGeocoder: CLGeocoder {
    var mockPlacemark: MockCLPlacemark?
    var shouldReturnError = false
    var shouldReturnEmptyPlacemarks = false
    var errorToReturn: Error?
    
    override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        if shouldReturnError {
            completionHandler(nil, errorToReturn)
            return
        }
        
        if shouldReturnEmptyPlacemarks {
            completionHandler([], nil)
            return
        }
        
        if let placemark = mockPlacemark {
            completionHandler([placemark], nil)
            return
        }
        
        // Default mock placemark if none specified
        let defaultPlacemark = MockCLPlacemark(
            thoroughfare: "Test Street",
            subThoroughfare: "1",
            locality: "Test City",
            subLocality: "Test Area",
            administrativeArea: "Test State",
            postalCode: "12345",
            country: "Test Country"
        )
        
        completionHandler([defaultPlacemark], nil)
    }
}

class MockCLPlacemark: CLPlacemark {
    private let _thoroughfare: String?
    private let _subThoroughfare: String?
    private let _locality: String?
    private let _subLocality: String?
    private let _administrativeArea: String?
    private let _postalCode: String?
    private let _country: String?
    
    init(thoroughfare: String?, subThoroughfare: String?, locality: String?, subLocality: String?, administrativeArea: String?, postalCode: String?, country: String?) {
        self._thoroughfare = thoroughfare
        self._subThoroughfare = subThoroughfare
        self._locality = locality
        self._subLocality = subLocality
        self._administrativeArea = administrativeArea
        self._postalCode = postalCode
        self._country = country
        super.init()
    }
    
    override var thoroughfare: String? {
        return _thoroughfare
    }
    
    override var subThoroughfare: String? {
        return _subThoroughfare
    }
    
    override var locality: String? {
        return _locality
    }
    
    override var subLocality: String? {
        return _subLocality
    }
    
    override var administrativeArea: String? {
        return _administrativeArea
    }
    
    override var postalCode: String? {
        return _postalCode
    }
    
    override var country: String? {
        return _country
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 