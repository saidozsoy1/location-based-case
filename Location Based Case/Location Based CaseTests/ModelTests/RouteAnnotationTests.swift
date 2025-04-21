import XCTest
import MapKit
@testable import Location_Based_Case

class RouteAnnotationTests: XCTestCase {
    
    func testInitialization() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let index = 5
        
        // When
        let annotation = RouteAnnotation(coordinate: coordinate, index: index)
        
        // Then
        XCTAssertEqual(annotation.coordinate.latitude, 41.0082)
        XCTAssertEqual(annotation.coordinate.longitude, 28.9784)
        XCTAssertEqual(annotation.index, 5)
        XCTAssertEqual(annotation.title, "Location Point 5")
        
        // Check subtitle format: "Lat: 41.00820, Lng: 28.97840"
        XCTAssertTrue(annotation.subtitle?.contains("Lat: 41.00820") ?? false)
        XCTAssertTrue(annotation.subtitle?.contains("Lng: 28.97840") ?? false)
    }
    
    func testDefaultIndex() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        
        // When - default index should be 1
        let annotation = RouteAnnotation(coordinate: coordinate)
        
        // Then
        XCTAssertEqual(annotation.index, 1)
        XCTAssertEqual(annotation.title, "Location Point 1")
    }
    
    func testMultipleAnnotationsWithSequentialIndices() {
        // Given
        let coordinate1 = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let coordinate2 = CLLocationCoordinate2D(latitude: 41.0090, longitude: 28.9790)
        let coordinate3 = CLLocationCoordinate2D(latitude: 41.0100, longitude: 28.9800)
        
        // When - create sequential annotations
        let annotation1 = RouteAnnotation(coordinate: coordinate1, index: 1)
        let annotation2 = RouteAnnotation(coordinate: coordinate2, index: 2)
        let annotation3 = RouteAnnotation(coordinate: coordinate3, index: 3)
        
        // Then
        XCTAssertEqual(annotation1.title, "Location Point 1")
        XCTAssertEqual(annotation2.title, "Location Point 2")
        XCTAssertEqual(annotation3.title, "Location Point 3")
        
        // Verify they have different coordinates
        XCTAssertNotEqual(annotation1.coordinate.latitude, annotation2.coordinate.latitude)
        XCTAssertNotEqual(annotation1.coordinate.longitude, annotation2.coordinate.longitude)
        XCTAssertNotEqual(annotation2.coordinate.latitude, annotation3.coordinate.latitude)
        XCTAssertNotEqual(annotation2.coordinate.longitude, annotation3.coordinate.longitude)
    }
    
    func testSubtitleFormat() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        
        // When
        let annotation = RouteAnnotation(coordinate: coordinate)
        
        // Then
        XCTAssertEqual(annotation.subtitle, "Lat: 41.00820, Lng: 28.97840")
    }
    
    func testConformanceToMKAnnotation() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let annotation = RouteAnnotation(coordinate: coordinate)
        
        // Then
        XCTAssertTrue(annotation is MKAnnotation)
    }
    
    func testPropertyUpdates() {
        // Given
        let initialCoordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        let annotation = RouteAnnotation(coordinate: initialCoordinate)
        
        // When - update the coordinate
        let newCoordinate = CLLocationCoordinate2D(latitude: 42.0082, longitude: 29.9784)
        annotation.coordinate = newCoordinate
        
        // Then
        XCTAssertEqual(annotation.coordinate.latitude, 42.0082)
        XCTAssertEqual(annotation.coordinate.longitude, 29.9784)
        
        // However, the subtitle would still reflect the initial coordinate
        // since it's only set during initialization
        XCTAssertTrue(annotation.subtitle?.contains("Lat: 41.00820") ?? false)
        
        // When - manually update the title and subtitle
        annotation.title = "New Title"
        annotation.subtitle = "New Subtitle"
        
        // Then
        XCTAssertEqual(annotation.title, "New Title")
        XCTAssertEqual(annotation.subtitle, "New Subtitle")
    }
} 
