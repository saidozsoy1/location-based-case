import Foundation
import CoreLocation
@testable import Location_Based_Case

class MockCLLocationManager: CLLocationManager {
    // Properties to track method calls
    var requestLocationCallCount = 0
    var startUpdatingLocationCallCount = 0
    var stopUpdatingLocationCallCount = 0
    var startMonitoringSignificantLocationChangesCallCount = 0
    var stopMonitoringSignificantLocationChangesCallCount = 0
    var requestWhenInUseAuthorizationCallCount = 0
    var requestAlwaysAuthorizationCallCount = 0
    
    // Properties to control mock behavior
    var _authorizationStatus: CLAuthorizationStatus = .notDetermined
    var _location: CLLocation?
    private var _delegateRef: CLLocationManagerDelegate?
    
    override var authorizationStatus: CLAuthorizationStatus {
        return _authorizationStatus
    }
    
    override var location: CLLocation? {
        return _location
    }
    
    override var delegate: CLLocationManagerDelegate? {
        get { return _delegateRef }
        set { _delegateRef = newValue }
    }
    
    // Methods to track calls
    override func requestLocation() {
        requestLocationCallCount += 1
    }
    
    override func startUpdatingLocation() {
        startUpdatingLocationCallCount += 1
    }
    
    override func stopUpdatingLocation() {
        stopUpdatingLocationCallCount += 1
    }
    
    override func startMonitoringSignificantLocationChanges() {
        startMonitoringSignificantLocationChangesCallCount += 1
    }
    
    override func stopMonitoringSignificantLocationChanges() {
        stopMonitoringSignificantLocationChangesCallCount += 1
    }
    
    override func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCallCount += 1
    }
    
    override func requestAlwaysAuthorization() {
        requestAlwaysAuthorizationCallCount += 1
    }
    
    // Helper methods for testing
    func simulateLocationUpdate(locations: [CLLocation]) {
        _location = locations.last
        delegate?.locationManager?(self, didUpdateLocations: locations)
    }
    
    func simulateAuthorizationChange(status: CLAuthorizationStatus) {
        _authorizationStatus = status
        delegate?.locationManager?(self, didChangeAuthorization: status)
    }
    
    func simulateError(error: Error) {
        delegate?.locationManager?(self, didFailWithError: error)
    }
} 