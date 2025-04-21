import XCTest
import CoreLocation
@testable import Location_Based_Case

class LocationManagerAdvancedTests: XCTestCase {
    
    var mockLocationManager: MockLocationManager!
    var mockDelegate: MockLocationManagerDelegate!
    
    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        mockDelegate = MockLocationManagerDelegate()
        mockLocationManager.delegate = mockDelegate
    }
    
    override func tearDown() {
        mockLocationManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testRequestLocation() {
        // When
        mockLocationManager.requestLocation()
        
        // Then
        XCTAssertEqual(mockLocationManager.requestLocationCallCount, 1, "requestLocation should be called exactly once")
    }
    
    func testRequestWhenInUseAuthorization() {
        // When
        mockLocationManager.requestWhenInUseAuthorization()
        
        // Then
        XCTAssertEqual(mockLocationManager.requestWhenInUseAuthorizationCallCount, 1, "requestWhenInUseAuthorization should be called exactly once")
    }
    
    func testRequestAlwaysAuthorization() {
        // When
        mockLocationManager.requestAlwaysAuthorization()
        
        // Then
        XCTAssertEqual(mockLocationManager.requestAlwaysAuthorizationCallCount, 1, "requestAlwaysAuthorization should be called exactly once")
    }
    
    func testStartUpdatingLocation() {
        // When
        mockLocationManager.startUpdatingLocation()
        
        // Then
        XCTAssertEqual(mockLocationManager.startUpdatingLocationCallCount, 1, "startUpdatingLocation should be called exactly once")
    }
    
    func testStopUpdatingLocation() {
        // When
        mockLocationManager.stopUpdatingLocation(shouldContinueInTheBackground: false)
        
        // Then
        XCTAssertEqual(mockLocationManager.stopUpdatingLocationCallCount, 1, "stopUpdatingLocation should be called exactly once")
    }
    
    func testStartMonitoringSignificantLocationChanges() {
        // When
        mockLocationManager.startMonitoringSignificantLocationChanges()
        
        // Then
        XCTAssertEqual(mockLocationManager.startMonitoringSignificantLocationChangesCallCount, 1, "startMonitoringSignificantLocationChanges should be called exactly once")
    }
    
    func testStopMonitoringSignificantLocationChanges() {
        // When
        mockLocationManager.stopMonitoringSignificantLocationChanges()
        
        // Then
        XCTAssertEqual(mockLocationManager.stopMonitoringSignificantLocationChangesCallCount, 1, "stopMonitoringSignificantLocationChanges should be called exactly once")
    }
    
    func testLastLocationUpdatedAfterLocationUpdate() {
        // Given
        let testLocation = CLLocation(latitude: 41.0082, longitude: 28.9784) // Istanbul coordinates
        
        // When
        mockLocationManager.simulateLocationUpdate(locations: [testLocation])
        
        // Then
        XCTAssertEqual(mockLocationManager.lastLocation?.coordinate.latitude, testLocation.coordinate.latitude)
        XCTAssertEqual(mockLocationManager.lastLocation?.coordinate.longitude, testLocation.coordinate.longitude)
        XCTAssertTrue(mockDelegate.updateLocationsCalled)
        XCTAssertEqual(mockDelegate.receivedLocations?.count, 1)
    }
    
    func testDelegateErrorCallback() {
        // Given
        let testError = NSError(domain: "TestErrorDomain", code: 123, userInfo: nil)
        
        // When
        mockLocationManager.simulateError(error: testError)
        
        // Then
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled)
        XCTAssertEqual((mockDelegate.receivedError as NSError?)?.domain, "TestErrorDomain")
        XCTAssertEqual((mockDelegate.receivedError as NSError?)?.code, 123)
    }
    
    func testDelegateAuthorizationCallback() {
        // When
        mockLocationManager.simulateAuthorizationChange(status: .authorizedAlways)
        
        // Then
        XCTAssertTrue(mockDelegate.didChangeAuthorizationStatusCalled)
        XCTAssertEqual(mockDelegate.receivedAuthorizationStatus, .authorizedAlways)
    }
    
    func testGetCurrentLocation() {
        // Given
        let testLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
        mockLocationManager.mockedCurrentLocation = testLocation
        
        // When
        let currentLocation = mockLocationManager.getCurrentLocation()
        
        // Then
        XCTAssertEqual(currentLocation?.coordinate.latitude, testLocation.coordinate.latitude)
        XCTAssertEqual(currentLocation?.coordinate.longitude, testLocation.coordinate.longitude)
    }
} 
