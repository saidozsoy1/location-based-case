import XCTest
import CoreLocation
@testable import Location_Based_Case

final class LocationManagerTests: XCTestCase {
    
    var locationManager: MockLocationManager!
    var mockDelegate: MockLocationManagerDelegate!
    
    override func setUp() {
        super.setUp()
        locationManager = MockLocationManager()
        mockDelegate = MockLocationManagerDelegate()
        locationManager.delegate = mockDelegate
    }
    
    override func tearDown() {
        locationManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testInitialization() {
        // Let's create a new locationManager to ensure its delegate is null
        let newLocationManager = MockLocationManager()
        XCTAssertNotNil(newLocationManager)
        XCTAssertNil(newLocationManager.delegate)
        XCTAssertNil(newLocationManager.lastLocation)
    }
    
    func testAuthorizationStatus() {
        // Set a specific status for testing
        locationManager.authorizationStatus = .authorizedWhenInUse
        let status = locationManager.authorizationStatus
        XCTAssertEqual(status, .authorizedWhenInUse)
    }
    
    func testDelegateMethodsAreCalled() {
        // Simulate location updates using the mock manager
        let testLocation = CLLocation(latitude: 41.0082, longitude: 28.9784) // Istanbul coordinates
        locationManager.simulateLocationUpdate(locations: [testLocation])
        
        // Verify delegate methods were called with correct parameters
        XCTAssertTrue(mockDelegate.updateLocationsCalled)
        XCTAssertEqual(mockDelegate.receivedLocations?.first?.coordinate.latitude, 41.0082)
        XCTAssertEqual(locationManager.lastLocation?.coordinate.latitude, 41.0082)
        
        // Test error handling
        let testError = NSError(domain: "LocationTestError", code: 1, userInfo: nil)
        locationManager.simulateError(error: testError)
        
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled)
        XCTAssertEqual((mockDelegate.receivedError as NSError?)?.domain, "LocationTestError")
        
        // Test authorization status changes
        locationManager.simulateAuthorizationChange(status: .authorizedWhenInUse)
        
        XCTAssertTrue(mockDelegate.didChangeAuthorizationStatusCalled)
        XCTAssertEqual(mockDelegate.receivedAuthorizationStatus, .authorizedWhenInUse)
    }
    
    func testStartUpdatingLocation() {
        // When
        locationManager.startUpdatingLocation()
        
        // Then
        XCTAssertEqual(locationManager.startUpdatingLocationCallCount, 1)
    }
    
    func testStopUpdatingLocation() {
        // When
        locationManager.stopUpdatingLocation(shouldContinueInTheBackground: false)
        
        // Then
        XCTAssertEqual(locationManager.stopUpdatingLocationCallCount, 1)
    }
    
    func testSignificantLocationChanges() {
        // Test start monitoring
        locationManager.startMonitoringSignificantLocationChanges()
        XCTAssertEqual(locationManager.startMonitoringSignificantLocationChangesCallCount, 1)
        
        // Test stop monitoring
        locationManager.stopMonitoringSignificantLocationChanges()
        XCTAssertEqual(locationManager.stopMonitoringSignificantLocationChangesCallCount, 1)
    }
    
    func testGetCurrentLocation() {
        // Given
        let testLocation = CLLocation(latitude: 41.0082, longitude: 28.9784)
        locationManager.mockedCurrentLocation = testLocation
        
        // When
        let currentLocation = locationManager.getCurrentLocation()
        
        // Then
        XCTAssertEqual(locationManager.getCurrentLocationCallCount, 1)
        XCTAssertEqual(currentLocation?.coordinate.latitude, testLocation.coordinate.latitude)
        XCTAssertEqual(currentLocation?.coordinate.longitude, testLocation.coordinate.longitude)
    }
    
    func testRequestLocation() {
        // When
        locationManager.requestLocation()
        
        // Then
        XCTAssertEqual(locationManager.requestLocationCallCount, 1)
    }
    
    func testRequestAuthorization() {
        // Test when in use
        locationManager.requestWhenInUseAuthorization()
        XCTAssertEqual(locationManager.requestWhenInUseAuthorizationCallCount, 1)
        
        // Test always
        locationManager.requestAlwaysAuthorization()
        XCTAssertEqual(locationManager.requestAlwaysAuthorizationCallCount, 1)
    }
}

final class MockLocationManagerDelegate: LocationManagerDelegate {
    var updateLocationsCalled = false
    var didChangeAuthorizationStatusCalled = false
    var didFailWithErrorCalled = false
    
    var receivedLocations: [CLLocation]?
    var receivedAuthorizationStatus: CLAuthorizationStatus?
    var receivedError: Error?
    
    func didUpdateLocations(_ locations: [CLLocation]) {
        updateLocationsCalled = true
        receivedLocations = locations
    }
    
    func didChangeAuthorizationStatus(_ status: CLAuthorizationStatus) {
        didChangeAuthorizationStatusCalled = true
        receivedAuthorizationStatus = status
    }
    
    func didFailWithError(_ error: Error) {
        didFailWithErrorCalled = true
        receivedError = error
    }
} 
