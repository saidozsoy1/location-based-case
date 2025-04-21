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
    var viewModel: MainViewModelProtocol!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var startStopTrackingButton: UIButton?
    @IBOutlet weak var resetRouteButton: UIButton?

    
    private var routeAnnotations: [RouteAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMap()
        setupViewModel()
    }
    
    @IBAction func toggleTracking(_ sender: Any) {
        viewModel.toggleTracking()
    }
    
    @IBAction func resetRoute(_ sender: Any) {
        clearAnnotations()
        viewModel.resetRoute()
    }
    
    private func setupUI() {
        statusLabel?.isHidden = true
        locationLabel?.isHidden = true
        startStopTrackingButton?.setTitle(L10n.Button.startTracking, for: .normal)
        resetRouteButton?.setTitle(L10n.Button.resetRoute, for: .normal)
        resetRouteButton?.isEnabled = !routeAnnotations.isEmpty
    }
    
    private func setupMap() {
        mapView.showsUserLocation = true
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
    
    private func updateMapForTracking(isTracking: Bool) {
        mapView.showsUserLocation = isTracking
        if !isTracking {
            mapView.setUserTrackingMode(.none, animated: true)
        }
    }
    
    private func updateLocationDisplay(_ location: CLLocation) {
        let latitudeStr = String(location.coordinate.latitude)
        let longitudeStr = String(location.coordinate.longitude)
        let latitudeText = L10n.Label.latitude(latitudeStr)
        let longitudeText = L10n.Label.longitude(longitudeStr)
        locationLabel?.text = "\(latitudeText)\n\(longitudeText)"
        locationLabel?.isHidden = false
    }
    
    private func setMapRegion(for location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
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
        hideLoading()
        showLocationErrorAlert(error: error)
    }
    
    func didAddRoutePoint(_ location: CLLocation) {
        DispatchQueue.main.async { [weak self] in
            let annotationIndex = (self?.routeAnnotations.count ?? 0) + 1
            let annotation = RouteAnnotation(coordinate: location.coordinate, index: annotationIndex)
            
            self?.mapView.addAnnotation(annotation)
            self?.routeAnnotations.append(annotation)
            self?.resetRouteButton?.isEnabled = true
        }
    }
    
    func didLoadSavedRoute(_ locations: [CLLocation]) {
        DispatchQueue.main.async { [weak self] in
            self?.clearAnnotations()

            var newAnnotations: [RouteAnnotation] = []
            
            for (index, location) in locations.enumerated() {
                let annotationIndex = index + 1
                let annotation = RouteAnnotation(coordinate: location.coordinate, index: annotationIndex)
                newAnnotations.append(annotation)
                self?.routeAnnotations.append(annotation)
            }
            
            if !newAnnotations.isEmpty {
                self?.mapView.addAnnotations(newAnnotations)
                self?.resetRouteButton?.isEnabled = true
                
                // Set region to the last location if available
                if let lastLocation = locations.last {
                    self?.setMapRegion(for: lastLocation)
                }
            }
        }
    }
    
    func didTrackingChange(_ isTrackingActive: Bool, trackingButtonText: String) {
        startStopTrackingButton?.setTitle(trackingButtonText, for: .normal)
    }
    
    func didRetrieveAddress(for annotation: RouteAnnotation, address: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.hideLoading()
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
        
        // Get address for the selected annotation
        if let routeAnnotation = annotation as? RouteAnnotation {
            showLoading()
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
