import MapKit

class RouteAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var index: Int
    
    var title: String? {
        return "Nokta \(index)"
    }
    
    var subtitle: String? {
        return String(format: "Lat: %.5f, Lon: %.5f", coordinate.latitude, coordinate.longitude)
    }
    
    init(coordinate: CLLocationCoordinate2D, index: Int) {
        self.coordinate = coordinate
        self.index = index
        super.init()
    }
} 