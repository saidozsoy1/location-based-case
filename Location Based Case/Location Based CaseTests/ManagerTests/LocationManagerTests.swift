import XCTest
import CoreLocation
@testable import Location_Based_Case

final class LocationManagerTests: XCTestCase {
    
    var locationManager: LocationManager!
    var mockDelegate: MockLocationManagerDelegate!
    
    override func setUp() {
        super.setUp()
        locationManager = LocationManager()
        mockDelegate = MockLocationManagerDelegate()
        locationManager.delegate = mockDelegate
    }
    
    override func tearDown() {
        locationManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testInitialization() {
        // Yeni bir locationManager oluşturalım ki delegate'i null olsun
        let newLocationManager = LocationManager()
        XCTAssertNotNil(newLocationManager)
        XCTAssertNil(newLocationManager.delegate)
        XCTAssertNil(newLocationManager.lastLocation)
    }
    
    func testAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        // Just verify we can access the status without crashing
        XCTAssertNotNil(status)
    }
    
    func testDelegateMethodsAreCalled() {
        // Manually trigger the CLLocationManagerDelegate methods
        let testLocation = CLLocation(latitude: 41.0082, longitude: 28.9784) // Istanbul coordinates
        locationManager.locationManager(CLLocationManager(), didUpdateLocations: [testLocation])
        
        // Verify delegate methods were called with correct parameters
        XCTAssertTrue(mockDelegate.updateLocationsCalled)
        XCTAssertEqual(mockDelegate.receivedLocations?.first?.coordinate.latitude, 41.0082)
        XCTAssertEqual(locationManager.lastLocation?.coordinate.latitude, 41.0082)
        
        // Test error handling
        let testError = NSError(domain: "LocationTestError", code: 1, userInfo: nil)
        locationManager.locationManager(CLLocationManager(), didFailWithError: testError)
        
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled)
        XCTAssertEqual((mockDelegate.receivedError as NSError?)?.domain, "LocationTestError")
        
        // Test authorization status changes
        locationManager.locationManager(CLLocationManager(), didChangeAuthorization: .authorizedWhenInUse)
        
        XCTAssertTrue(mockDelegate.didChangeAuthorizationStatusCalled)
        XCTAssertEqual(mockDelegate.receivedAuthorizationStatus, .authorizedWhenInUse)
    }
    
    func testStartUpdatingLocation() {
        // This is a limited test since we can't easily mock the internal CLLocationManager
        // We're just checking that the method doesn't crash
        locationManager.startUpdatingLocation()
    }
    
    func testStopUpdatingLocation() {
        // Again, a limited test for method existence
        locationManager.stopUpdatingLocation(shouldContinueInTheBackground: false)
        locationManager.stopUpdatingLocation(shouldContinueInTheBackground: true)
    }
    
    func testSignificantLocationChanges() {
        // Test that these methods don't crash
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.stopMonitoringSignificantLocationChanges()
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
