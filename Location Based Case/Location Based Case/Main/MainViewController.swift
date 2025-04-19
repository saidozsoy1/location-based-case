//
//  MainViewController.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 18.04.2025.
//

import UIKit
import CoreLocation
import MapKit

final class MainViewController: UIViewController {
    var viewModel: MainViewModel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var startStopTrackingButton: UIButton?
    @IBOutlet weak var resetRouteButton: UIButton?

    
    private var routeAnnotations: [RouteAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("didload main")
        
        setupUI()
        setupMap()
        setupViewModel()
        updateTrackingButtonState()
        mapView.showsUserLocation = viewModel.isTracking
    }
    
    @IBAction func toggleTracking(_ sender: Any) {
        viewModel.isTracking ? stopLocationTracking() : startLocationTracking()
    }
    
    @IBAction func resetRoute(_ sender: Any) {
        clearAnnotations()
        viewModel.resetRoute()
    }
    
    private func setupUI() {
        statusLabel?.isHidden = true
        locationLabel?.isHidden = true
        resetRouteButton?.isEnabled = !routeAnnotations.isEmpty
    }
    
    private func setupMap() {
        mapView.showsUserTrackingButton = true
        mapView.delegate = self
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
        if let location = viewModel.currentLocation {
            updateLocationDisplay(location)
        }
        viewModel.loadSavedRoute()
    }
    
    private func startLocationTracking() {
        viewModel.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    private func stopLocationTracking() {
        viewModel.stopUpdatingLocation()
        mapView.showsUserLocation = false
        mapView.setUserTrackingMode(.none, animated: true)
        if let location = viewModel.currentLocation {
            updateLocationDisplay(location)
        }
    }
    
    private func updateTrackingButtonState() {
        let title = viewModel.isTracking ? "Stop Tracking" : "Start Tracking"
        startStopTrackingButton?.setTitle(title, for: .normal)
    }
    
    private func updateLocationDisplay(_ location: CLLocation) {
        locationLabel?.text = "Latitude: \(location.coordinate.latitude)\nLongitude: \(location.coordinate.longitude)"
        locationLabel?.isHidden = false
    }
    
    private func setMapRegion(for location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
    }
    
    private func addAnnotation(for location: CLLocation) {
        let annotationIndex = routeAnnotations.count + 1
        let annotation = RouteAnnotation(coordinate: location.coordinate, index: annotationIndex)
        mapView.addAnnotation(annotation)
        routeAnnotations.append(annotation)
        resetRouteButton?.isEnabled = true
    }
    
    private func clearAnnotations() {
        mapView.removeAnnotations(routeAnnotations)
        routeAnnotations.removeAll()
        resetRouteButton?.isEnabled = false
    }
    
    private func updateAuthorizationStatusText(_ text: String?) {
        statusLabel?.text = text
        UIView.animate(withDuration: 0.25) { // doesnt require weak self
            self.statusLabel?.isHidden = false
        }
    }
}

extension MainViewController: MainViewModelDelegate {
    func didUpdateLocation(_ location: CLLocation) {
        updateLocationDisplay(location)
    }
    
    func didChangeAuthorizationStatus(statusText: String?) {
        updateAuthorizationStatusText(statusText)
    }
    
    func didFailWithError(_ error: Error) {
        showLocationErrorAlert(error: error)
    }
    
    func didAddRoutePoint(_ location: CLLocation) {
        DispatchQueue.main.async { [weak self] in
            self?.addAnnotation(for: location)
        }
    }
    
    func didLoadSavedRoute(_ locations: [CLLocation]) {
        DispatchQueue.main.async { [weak self] in
            self?.clearAnnotations()
            
            for location in locations {
                self?.addAnnotation(for: location)
            }
            
            if let lastLocation = locations.last {
                self?.setMapRegion(for: lastLocation)
            }
        }
    }
    
    func didTrackingChange(_ isTrackingActive: Bool) {
        updateTrackingButtonState()
    }
    
    func didRetrieveAddress(for annotation: RouteAnnotation, address: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.showAddressAlert(address: address)
        }
    }
    
    func didUpdateLocationForAddress(_ location: CLLocation?) {
        if let location = location {
            setMapRegion(for: location)
        }
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        // Skip user location annotation
        if annotation is MKUserLocation {
            return
        }
        
        // Adres bilgisini al
        if let routeAnnotation = annotation as? RouteAnnotation {
            viewModel.getAddressForAnnotation(routeAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil // Use default for user location
        }
        
        let identifier = "routeAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
