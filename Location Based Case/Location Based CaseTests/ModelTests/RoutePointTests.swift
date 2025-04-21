import XCTest
import CoreLocation
@testable import Location_Based_Case

class RoutePointTests: XCTestCase {
    
    func testInitFromLocation() {
        // Given
        let date = Date()
        let coordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let location = CLLocation(coordinate: coordinate, altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: date)
        
        // When
        let routePoint = RoutePoint(location: location)
        
        // Then
        XCTAssertEqual(routePoint.latitude, 41.0082)
        XCTAssertEqual(routePoint.longitude, 28.9784)
        XCTAssertEqual(routePoint.timestamp, date.timeIntervalSince1970)
    }
    
    func testInitFromRawValues() {
        // Given
        let latitude = 41.0082
        let longitude = 28.9784
        let timestamp = Date().timeIntervalSince1970
        
        // When
        let routePoint = RoutePoint(latitude: latitude, longitude: longitude, timestamp: timestamp)
        
        // Then
        XCTAssertEqual(routePoint.latitude, latitude)
        XCTAssertEqual(routePoint.longitude, longitude)
        XCTAssertEqual(routePoint.timestamp, timestamp)
    }
    
    func testToLocation() {
        // Given
        let latitude = 41.0082
        let longitude = 28.9784
        let timestamp = Date().timeIntervalSince1970
        let routePoint = RoutePoint(latitude: latitude, longitude: longitude, timestamp: timestamp)
        
        // When
        let location = routePoint.toLocation()
        
        // Then
        XCTAssertEqual(location.coordinate.latitude, latitude)
        XCTAssertEqual(location.coordinate.longitude, longitude)
        XCTAssertEqual(location.timestamp.timeIntervalSince1970, timestamp)
        XCTAssertEqual(location.altitude, 0)
        XCTAssertEqual(location.horizontalAccuracy, 0)
        XCTAssertEqual(location.verticalAccuracy, 0)
    }
    
    func testCodable() throws {
        // Given
        let routePoint = RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: Date().timeIntervalSince1970)
        
        // When - encode to data
        let encoder = JSONEncoder()
        let data = try encoder.encode(routePoint)
        
        // Then - decode from data
        let decoder = JSONDecoder()
        let decodedRoutePoint = try decoder.decode(RoutePoint.self, from: data)
        
        // Assert equal
        XCTAssertEqual(decodedRoutePoint.latitude, routePoint.latitude)
        XCTAssertEqual(decodedRoutePoint.longitude, routePoint.longitude)
        XCTAssertEqual(decodedRoutePoint.timestamp, routePoint.timestamp)
    }
    
    func testEquality() {
        // Given
        let timestamp = Date().timeIntervalSince1970
        let routePoint1 = RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: timestamp)
        let routePoint2 = RoutePoint(latitude: 41.0082, longitude: 28.9784, timestamp: timestamp)
        let routePoint3 = RoutePoint(latitude: 41.0090, longitude: 28.9790, timestamp: timestamp)
        
        // Then - Since RoutePoint is a struct, it gets automatic value-based equality
        XCTAssertEqual(routePoint1.latitude, routePoint2.latitude)
        XCTAssertEqual(routePoint1.longitude, routePoint2.longitude)
        XCTAssertEqual(routePoint1.timestamp, routePoint2.timestamp)
        
        XCTAssertNotEqual(routePoint1.latitude, routePoint3.latitude)
        XCTAssertNotEqual(routePoint1.longitude, routePoint3.longitude)
    }
    
    func testRoundTripConversion() {
        // Given
        let date = Date()
        let originalCoordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let originalLocation = CLLocation(
            coordinate: originalCoordinate, 
            altitude: 100, 
            horizontalAccuracy: 10, 
            verticalAccuracy: 10, 
            timestamp: date
        )
        
        // When - convert to RoutePoint and back
        let routePoint = RoutePoint(location: originalLocation)
        let convertedLocation = routePoint.toLocation()
        
        // Then - verify core properties are preserved
        XCTAssertEqual(convertedLocation.coordinate.latitude, originalLocation.coordinate.latitude)
        XCTAssertEqual(convertedLocation.coordinate.longitude, originalLocation.coordinate.longitude)
        XCTAssertEqual(convertedLocation.timestamp.timeIntervalSince1970, originalLocation.timestamp.timeIntervalSince1970)
        
        // Note: altitude and accuracy values are not preserved in RoutePoint
        XCTAssertEqual(convertedLocation.altitude, 0)
        XCTAssertEqual(convertedLocation.horizontalAccuracy, 0)
        XCTAssertEqual(convertedLocation.verticalAccuracy, 0)
    }
} 