import XCTest
import CoreLocation
import MapKit
@testable import Location_Based_Case

class DataManagerTests: XCTestCase {
    
    var sut: DataManaging!
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
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970),
            RoutePoint(latitude: 41.0102, longitude: 28.9802, timestamp: Date().timeIntervalSince1970)
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
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970),
            RoutePoint(latitude: 41.0102, longitude: 28.9802, timestamp: Date().timeIntervalSince1970)
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
        let now = Date().timeIntervalSince1970
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

protocol CLPlacemarkProtocol {
    var thoroughfare: String? { get }
    var subThoroughfare: String? { get }
    var locality: String? { get }
    var subLocality: String? { get }
    var administrativeArea: String? { get }
    var postalCode: String? { get }
    var country: String? { get }
}

extension CLPlacemark: CLPlacemarkProtocol {}

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
            // Create a real CLPlacemark from our mock data
            // Since we can't directly instantiate CLPlacemark, we'll use our mock's data
            // In real tests, the actual data doesn't matter as much as the behavior
            let mockDict: [String: Any] = [
                "thoroughfare": placemark.thoroughfare as Any,
                "subThoroughfare": placemark.subThoroughfare as Any,
                "locality": placemark.locality as Any,
                "subLocality": placemark.subLocality as Any,
                "administrativeArea": placemark.administrativeArea as Any,
                "postalCode": placemark.postalCode as Any,
                "country": placemark.country as Any
            ]
            
            let realPlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: mockDict)
            completionHandler([realPlacemark], nil)
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
        
        let mockDict: [String: Any] = [
            "thoroughfare": defaultPlacemark.thoroughfare as Any,
            "subThoroughfare": defaultPlacemark.subThoroughfare as Any,
            "locality": defaultPlacemark.locality as Any,
            "subLocality": defaultPlacemark.subLocality as Any,
            "administrativeArea": defaultPlacemark.administrativeArea as Any,
            "postalCode": defaultPlacemark.postalCode as Any,
            "country": defaultPlacemark.country as Any
        ]
        
        let realPlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: mockDict)
        completionHandler([realPlacemark], nil)
    }
}

class MockCLPlacemark: CLPlacemarkProtocol {
    let thoroughfare: String?
    let subThoroughfare: String?
    let locality: String?
    let subLocality: String?
    let administrativeArea: String?
    let postalCode: String?
    let country: String?
    
    init(thoroughfare: String?, subThoroughfare: String?, locality: String?, subLocality: String?, administrativeArea: String?, postalCode: String?, country: String?) {
        self.thoroughfare = thoroughfare
        self.subThoroughfare = subThoroughfare
        self.locality = locality
        self.subLocality = subLocality
        self.administrativeArea = administrativeArea
        self.postalCode = postalCode
        self.country = country
    }
} 
