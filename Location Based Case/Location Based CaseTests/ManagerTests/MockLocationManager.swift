import Foundation
import CoreLocation
@testable import Location_Based_Case

class MockLocationManager: LocationManaging {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var lastLocation: CLLocation? = nil
    weak var delegate: LocationManagerDelegate?
    
    var getCurrentLocationCallCount = 0
    var requestLocationCallCount = 0
    var requestWhenInUseAuthorizationCallCount = 0
    var requestAlwaysAuthorizationCallCount = 0
    var startUpdatingLocationCallCount = 0
    var stopUpdatingLocationCallCount = 0
    var startMonitoringSignificantLocationChangesCallCount = 0
    var stopMonitoringSignificantLocationChangesCallCount = 0
    
    // For controlling the return value in tests
    var mockedCurrentLocation: CLLocation?
    
    func getCurrentLocation() -> CLLocation? {
        getCurrentLocationCallCount += 1
        return mockedCurrentLocation
    }
    
    func requestLocation() {
        requestLocationCallCount += 1
    }
    
    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCallCount += 1
    }
    
    func requestAlwaysAuthorization() {
        requestAlwaysAuthorizationCallCount += 1
    }
    
    func startUpdatingLocation() {
        startUpdatingLocationCallCount += 1
    }
    
    func stopUpdatingLocation(shouldContinueInTheBackground: Bool) {
        stopUpdatingLocationCallCount += 1
    }
    
    func startMonitoringSignificantLocationChanges() {
        startMonitoringSignificantLocationChangesCallCount += 1
    }
    
    func stopMonitoringSignificantLocationChanges() {
        stopMonitoringSignificantLocationChangesCallCount += 1
    }
    
    // Helper method to simulate location updates
    func simulateLocationUpdate(locations: [CLLocation]) {
        lastLocation = locations.last
        delegate?.didUpdateLocations(locations)
    }
    
    // Helper method to simulate authorization changes
    func simulateAuthorizationChange(status: CLAuthorizationStatus) {
        authorizationStatus = status
        delegate?.didChangeAuthorizationStatus(status)
    }
    
    // Helper method to simulate errors
    func simulateError(error: Error) {
        delegate?.didFailWithError(error)
    }
} 
