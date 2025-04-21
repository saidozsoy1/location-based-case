import XCTest
import CoreLocation
@testable import Location_Based_Case

class MainViewModelTests: XCTestCase {
    
    var sut: MainViewModelProtocol!
    var mockLocationManager: MockLocationManager!
    var mockDataManager: MockDataManager!
    var mockDelegate: MockMainViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        mockDataManager = MockDataManager()
        mockDelegate = MockMainViewModelDelegate()
        
        sut = MainViewModel(locationManager: mockLocationManager, dataManager: mockDataManager)
        sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        sut = nil
        mockLocationManager = nil
        mockDataManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // When initialized, MainViewModel should...
        
        // 1. Set itself as the location manager's delegate
        XCTAssertTrue(mockLocationManager.delegate === sut)
        
        // 2. Try to load saved route
        XCTAssertEqual(mockDataManager.loadRoutePointsCallCount, 1)
        
        // 3. Register for background/foreground notifications
        // Not directly testable, but we can verify handler behavior in other tests
    }
    
    // MARK: - Permission Status Tests
    
    func testGetPermissionStatusWhenAuthorized() {
        // Given
        mockLocationManager.authorizationStatus = .authorizedAlways
        
        // When
        let status = sut.getPermissionStatus()
        
        // Then
        XCTAssertEqual(status, .permitted)
    }
    
    func testGetPermissionStatusWhenDenied() {
        // Given
        mockLocationManager.authorizationStatus = .denied
        
        // When
        let status = sut.getPermissionStatus()
        
        // Then
        XCTAssertEqual(status, .denied)
    }
    
    func testGetPermissionStatusWhenRestricted() {
        // Given
        mockLocationManager.authorizationStatus = .restricted
        
        // When
        let status = sut.getPermissionStatus()
        
        // Then
        XCTAssertEqual(status, .restricted)
    }
    
    func testGetPermissionStatusWhenUndetermined() {
        // Given
        mockLocationManager.authorizationStatus = .notDetermined
        
        // When
        let status = sut.getPermissionStatus()
        
        // Then
        XCTAssertEqual(status, .undetermined)
    }
    
    // MARK: - Tracking Tests
    
    func testStartTrackingWhenPermitted() {
        // Given
        mockLocationManager.authorizationStatus = .authorizedAlways
        
        // When
        sut.startTracking()
        
        // Need to wait for async operation to complete
        let expectation = self.expectation(description: "Start tracking")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then
        XCTAssertTrue(sut.isTracking)
        XCTAssertEqual(mockLocationManager.startUpdatingLocationCallCount, 1)
        XCTAssertTrue(mockDelegate.didTrackingChangeCalled)
        XCTAssertTrue(mockDelegate.isTrackingActive)
        XCTAssertTrue(mockDelegate.locationPermissionGrantedCalled)
    }
    
    func testStartTrackingWhenDenied() {
        // Given
        mockLocationManager.authorizationStatus = .denied
        
        // When
        sut.startTracking()
        
        // Need to wait for async operation to complete
        let expectation = self.expectation(description: "Start tracking denied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then
        XCTAssertFalse(sut.isTracking)
        XCTAssertEqual(mockLocationManager.startUpdatingLocationCallCount, 0)
        XCTAssertTrue(mockDelegate.showPermissionAlertCalled)
    }
    
    func testStartTrackingWhenUndetermined() {
        // Given
        mockLocationManager.authorizationStatus = .notDetermined
        
        // When
        sut.startTracking()
        
        // Need to wait for async operation to complete
        let expectation = self.expectation(description: "Start tracking undetermined")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then
        XCTAssertEqual(mockLocationManager.requestAlwaysAuthorizationCallCount, 1)
        // Permission request doesn't immediately change tracking state
        XCTAssertFalse(sut.isTracking)
    }
    
    func testStopTracking() {
        // Given
        mockLocationManager.authorizationStatus = .authorizedAlways
        sut.startTracking()
        
        // Wait for start tracking to complete
        let startExpectation = self.expectation(description: "Start tracking")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            startExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Reset delegate tracking
        mockDelegate.reset()
        
        // When
        sut.stopTracking()
        
        // Then
        XCTAssertFalse(sut.isTracking)
        XCTAssertEqual(mockLocationManager.stopUpdatingLocationCallCount, 1)
        XCTAssertTrue(mockDelegate.didTrackingChangeCalled)
        XCTAssertFalse(mockDelegate.isTrackingActive)
    }
    
    func testToggleTracking() {
        // Given
        mockLocationManager.authorizationStatus = .authorizedAlways
        
        // When - toggle on
        sut.toggleTracking()
        
        // Wait for toggle on to complete
        let toggleOnExpectation = self.expectation(description: "Toggle on")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            toggleOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then - should be tracking
        XCTAssertTrue(sut.isTracking)
        XCTAssertEqual(mockLocationManager.startUpdatingLocationCallCount, 1)
        
        // Reset delegate tracking
        mockDelegate.reset()
        
        // When - toggle off
        sut.toggleTracking()
        
        // Then - should not be tracking
        XCTAssertFalse(sut.isTracking)
        XCTAssertEqual(mockLocationManager.stopUpdatingLocationCallCount, 1)
    }
    
    func testRequestAlwaysPermission() {
        // When
        sut.requestAlwaysPermission()
        
        // Then
        XCTAssertEqual(mockLocationManager.requestAlwaysAuthorizationCallCount, 1)
    }
    
    func testRequestLocation() {
        // When
        sut.requestLocation()
        
        // Then
        XCTAssertEqual(mockLocationManager.requestLocationCallCount, 1)
    }
    
    // MARK: - Background/Foreground Handling Tests
    
    func testAppDidEnterBackground() {
        // When
        sut.appDidEnterBackground()
        
        // Then
        XCTAssertEqual(mockLocationManager.startMonitoringSignificantLocationChangesCallCount, 1)
    }
    
    func testAppWillEnterForeground() {
        // When
        sut.appWillEnterForeground()
        
        // Then
        XCTAssertEqual(mockLocationManager.stopMonitoringSignificantLocationChangesCallCount, 1)
    }
    
    // MARK: - Route Management Tests
    
    func testLoadSavedRoute() {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970),
            RoutePoint(latitude: 41.0090, longitude: 28.9790, timestamp: Date().timeIntervalSince1970 + 60)
        ]
        mockDataManager.mockRoutePoints = routePoints
        
        // Make sure loadSavedRoute is called again (already called once in setUp)
        mockDelegate.reset()
        mockDataManager.loadRoutePointsCallCount = 0
        
        // When
        sut.loadSavedRoute()
        
        // Then
        XCTAssertEqual(mockDataManager.loadRoutePointsCallCount, 1)
        XCTAssertTrue(mockDelegate.didLoadSavedRouteCalled)
        XCTAssertEqual(mockDelegate.receivedLocations?.count, 2)
    }
    
    func testLoadSavedRouteWithError() {
        // Given
        mockDataManager.shouldThrowOnLoad = true
        
        // Make sure loadSavedRoute is called again (already called once in setUp)
        mockDelegate.reset()
        mockDataManager.loadRoutePointsCallCount = 0
        
        // When
        sut.loadSavedRoute()
        
        // Then - should have tried to load but handled the error
        XCTAssertEqual(mockDataManager.loadRoutePointsCallCount, 1)
        // No delegate call since there was an error
        XCTAssertFalse(mockDelegate.didLoadSavedRouteCalled)
    }
    
    func testResetRoute() {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970),
            RoutePoint(latitude: 41.0090, longitude: 28.9790, timestamp: Date().timeIntervalSince1970 + 60)
        ]
        mockDataManager.mockRoutePoints = routePoints
        sut.loadSavedRoute()
        
        // Reset delegate for clean test
        mockDelegate.reset()
        
        // When
        sut.resetRoute()
        
        // Then
        XCTAssertEqual(mockDataManager.clearRoutePointsCallCount, 1)
        XCTAssertTrue(mockDelegate.didLoadSavedRouteCalled)
        XCTAssertEqual(mockDelegate.receivedLocations?.count, 0)
    }
    
    // MARK: - Location Updates Tests
    
    func testLocationUpdateAddsRoutePoint() {
        // Given
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
            altitude: 100,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: Date()
        )
        
        // When
        sut.didUpdateLocations([location])
        
        // Then
        XCTAssertTrue(mockDelegate.didUpdateLocationCalled)
        XCTAssertEqual(mockDelegate.receivedLocation?.coordinate.latitude, 41.0082)
        XCTAssertTrue(mockDelegate.didAddRoutePointCalled)
        XCTAssertEqual(mockDelegate.addedRoutePoint?.coordinate.latitude, 41.0082)
        
        // Should attempt to save route
        XCTAssertEqual(mockDataManager.convertToRoutePointsCallCount, 1)
        XCTAssertEqual(mockDataManager.saveRoutePointsCallCount, 1)
    }
    
    func testLocationUpdateWithinThresholdDoesNotAddRoutePoint() {
        // Given - add a first point
        let firstLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
            altitude: 100,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: Date()
        )
        sut.didUpdateLocations([firstLocation])
        
        // Reset counters and flags
        mockDelegate.reset()
        mockDataManager.saveRoutePointsCallCount = 0
        
        // When - add a second point very close to the first (less than minimum threshold)
        let secondLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 41.0082001, longitude: 28.9784001),
            altitude: 100,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: Date()
        )
        sut.didUpdateLocations([secondLocation])
        
        // Then
        XCTAssertTrue(mockDelegate.didUpdateLocationCalled)
        XCTAssertFalse(mockDelegate.didAddRoutePointCalled) // Should not add the point
        XCTAssertEqual(mockDataManager.saveRoutePointsCallCount, 0) // Should not attempt to save
    }
    
    func testLocationUpdateErrorHandling() {
        // Given
        let routePoints = [
            RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)
        ]
        mockDataManager.mockRoutePoints = routePoints
        mockDataManager.shouldThrowOnSave = true
        
        // When
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 41.0090, longitude: 28.9790),
            altitude: 100,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: Date()
        )
        sut.didUpdateLocations([location])
        
        // Then - save should fail but shouldn't crash
        XCTAssertEqual(mockDataManager.saveRoutePointsCallCount, 1)
        // Point is still added to delegate even though save fails
        XCTAssertTrue(mockDelegate.didAddRoutePointCalled)
    }
    
    // MARK: - Error Handling Tests
    
    func testLocationErrorCallsDelegate() {
        // Given
        let testError = NSError(domain: "TestErrorDomain", code: 123, userInfo: nil)
        
        // When
        sut.didFailWithError(testError)
        
        // Then
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled)
        XCTAssertEqual((mockDelegate.receivedError as NSError?)?.domain, "TestErrorDomain")
    }
    
    func testAuthorizationStatusChange() {
        // Given
        let status = CLAuthorizationStatus.authorizedAlways
        
        // When
        sut.didChangeAuthorizationStatus(status)
        
        // Then
        XCTAssertTrue(mockDelegate.didChangeAuthorizationStatusCalled)
        XCTAssertNotNil(mockDelegate.receivedStatusText)
    }
    
    // MARK: - Geocoding Tests
    
    func testGetAddressForAnnotation() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let annotation = RouteAnnotation(coordinate: coordinate)
        mockDataManager.mockAddress = "Test Address"
        
        // When
        sut.getAddressForAnnotation(annotation)
        
        // Then
        XCTAssertEqual(mockDataManager.getAddressFromLocationCallCount, 1)
        XCTAssertTrue(mockDelegate.didRetrieveAddressCalled)
        XCTAssertEqual(mockDelegate.receivedAddress, "Test Address")
    }
    
    func testGetAddressForAnnotationWithError() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let annotation = RouteAnnotation(coordinate: coordinate)
        mockDataManager.mockAddressError = NSError(domain: "GeocodingError", code: 1, userInfo: nil)
        
        // When
        sut.getAddressForAnnotation(annotation)
        
        // Then
        XCTAssertEqual(mockDataManager.getAddressFromLocationCallCount, 1)
        XCTAssertTrue(mockDelegate.didRetrieveAddressCalled)
        XCTAssertNil(mockDelegate.receivedAddress)
    }
    
    // MARK: - Location Permission Tests
    
    func testLocationPermissionGrantedCalledWhenStartingTrackingWithPermission() {
        // Given
        mockLocationManager.authorizationStatus = .authorizedAlways
        mockDelegate.reset()
        
        // When
        sut.startTracking()
        
        // Need to wait for async operation to complete
        let expectation = self.expectation(description: "Wait for permission granted")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then
        XCTAssertTrue(mockDelegate.locationPermissionGrantedCalled, "locationPermissionGranted should be called when tracking starts with permission")
    }
}

// MARK: - Mock MainViewModelDelegate

class MockMainViewModelDelegate: MainViewModelDelegate {
    // Flags to track if methods were called
    var didUpdateLocationCalled = false
    var didChangeAuthorizationStatusCalled = false
    var didFailWithErrorCalled = false
    var didAddRoutePointCalled = false
    var didLoadSavedRouteCalled = false
    var didTrackingChangeCalled = false
    var didRetrieveAddressCalled = false
    var showPermissionAlertCalled = false
    var locationPermissionGrantedCalled = false
    
    // Values received by delegate methods
    var receivedLocation: CLLocation?
    var receivedStatusText: String?
    var receivedError: Error?
    var addedRoutePoint: CLLocation?
    var receivedLocations: [CLLocation]?
    var isTrackingActive = false
    var trackingButtonText: String?
    var receivedAnnotation: RouteAnnotation?
    var receivedAddress: String?
    
    func didUpdateLocation(_ location: CLLocation) {
        didUpdateLocationCalled = true
        receivedLocation = location
    }
    
    func didChangeAuthorizationStatus(statusText: String?) {
        didChangeAuthorizationStatusCalled = true
        receivedStatusText = statusText
    }
    
    func didFailWithError(_ error: Error) {
        didFailWithErrorCalled = true
        receivedError = error
    }
    
    func didAddRoutePoint(_ location: CLLocation) {
        didAddRoutePointCalled = true
        addedRoutePoint = location
    }
    
    func didLoadSavedRoute(_ locations: [CLLocation]) {
        didLoadSavedRouteCalled = true
        receivedLocations = locations
    }
    
    func didTrackingChange(_ isTrackingActive: Bool, trackingButtonText: String) {
        didTrackingChangeCalled = true
        self.isTrackingActive = isTrackingActive
        self.trackingButtonText = trackingButtonText
    }
    
    func didRetrieveAddress(for annotation: RouteAnnotation, address: String?) {
        didRetrieveAddressCalled = true
        receivedAnnotation = annotation
        receivedAddress = address
    }
    
    func showPermissionAlert() {
        showPermissionAlertCalled = true
    }
    
    func locationPermissionGranted() {
        locationPermissionGrantedCalled = true
    }
    
    func reset() {
        didUpdateLocationCalled = false
        didChangeAuthorizationStatusCalled = false
        didFailWithErrorCalled = false
        didAddRoutePointCalled = false
        didLoadSavedRouteCalled = false
        didTrackingChangeCalled = false
        didRetrieveAddressCalled = false
        showPermissionAlertCalled = false
        locationPermissionGrantedCalled = false
        
        receivedLocation = nil
        receivedStatusText = nil
        receivedError = nil
        addedRoutePoint = nil
        receivedLocations = nil
        isTrackingActive = false
        trackingButtonText = nil
        receivedAnnotation = nil
        receivedAddress = nil
    }
}

// MARK: - MockDataManager for MainViewModel Tests

class MockDataManager: DataManaging {
    // Call tracking
    var saveRoutePointsCallCount = 0
    var loadRoutePointsCallCount = 0
    var clearRoutePointsCallCount = 0
    var convertToLocationsCallCount = 0
    var convertToRoutePointsCallCount = 0
    var getAddressFromLocationCallCount = 0
    
    // Mock data
    var mockRoutePoints: [RoutePoint]?
    var mockAddress: String?
    var mockAddressError: Error?
    
    // Test flags
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    
    // Stored results
    private var storedRoutePoints: [RoutePoint] = []
    
    func saveRoutePoints(_ routePoints: [RoutePoint]) throws {
        saveRoutePointsCallCount += 1
        
        if shouldThrowOnSave {
            throw NSError(domain: "MockDataManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock save error"])
        }
        
        storedRoutePoints = routePoints
        mockRoutePoints = routePoints
    }
    
    func loadRoutePoints() throws -> [RoutePoint]? {
        loadRoutePointsCallCount += 1
        
        if shouldThrowOnLoad {
            throw NSError(domain: "MockDataManagerError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Mock load error"])
        }
        
        return mockRoutePoints ?? storedRoutePoints
    }
    
    func clearRoutePoints() {
        clearRoutePointsCallCount += 1
        storedRoutePoints.removeAll()
        mockRoutePoints = nil
    }
    
    func convertToLocations(_ routePoints: [RoutePoint]) -> [CLLocation] {
        convertToLocationsCallCount += 1
        return routePoints.map { 
            CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                altitude: 0,
                horizontalAccuracy: 0,
                verticalAccuracy: 0,
                timestamp: Date(timeIntervalSince1970: $0.timestamp)
            )
        }
    }
    
    func convertToRoutePoints(_ locations: [CLLocation]) -> [RoutePoint] {
        convertToRoutePointsCallCount += 1
        return locations.map { RoutePoint(location: $0) }
    }
    
    func getAddressFromLocation(_ location: CLLocation, completion: @escaping (String?, Error?) -> Void) {
        getAddressFromLocationCallCount += 1
        
        // If specific error is set, return that
        if let mockError = mockAddressError {
            completion(nil, mockError)
            return
        }
        
        // If specific address is set, return that
        if let address = mockAddress {
            completion(address, nil)
            return
        }
        
        // Default behavior: create a formatted address from coordinates
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let address = "Test Address at coordinates: \(latitude), \(longitude)"
        completion(address, nil)
    }
    
    // Helper method to reset all counters and flags
    func reset() {
        saveRoutePointsCallCount = 0
        loadRoutePointsCallCount = 0
        clearRoutePointsCallCount = 0
        convertToLocationsCallCount = 0
        convertToRoutePointsCallCount = 0
        getAddressFromLocationCallCount = 0
        
        shouldThrowOnSave = false
        shouldThrowOnLoad = false
        
        mockRoutePoints = nil
        mockAddress = nil
        mockAddressError = nil
        storedRoutePoints.removeAll()
    }
} 
