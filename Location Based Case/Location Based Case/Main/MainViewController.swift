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

    
    private var isTracking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("didload main")
        
        setupUI()
        setupMap()
        setupViewModel()
        updateTrackingButtonState()
        updateAuthorizationStatus(viewModel.authorizationStatus)
    }
    
    @IBAction func toggleTracking(_ sender: Any) {
        isTracking.toggle()
        isTracking ? startLocationTracking() : stopLocationTracking()
        
        updateTrackingButtonState()
    }
    
    @IBAction func resetRoute(_ sender: Any) {
        
    }
    
    private func setupUI() {
        
    }
    
    private func setupMap() {
        mapView.showsUserTrackingButton = true
        mapView.showsUserLocation = true
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
        
        // If we already have a location, update right away
        if let location = viewModel.currentLocation {
            updateLocationDisplay(location)
        }
    }
    
    private func startLocationTracking() {
        viewModel.startUpdatingLocation()
        locationLabel?.text = "Tracking location..."
    }
    
    private func stopLocationTracking() {
        viewModel.stopUpdatingLocation()
        if let location = viewModel.currentLocation {
            updateLocationDisplay(location)
        } else {
            locationLabel?.text = "Location tracking stopped"
        }
    }
    
    private func updateTrackingButtonState() {
        let title = isTracking ? "Stop Tracking" : "Start Tracking"
        startStopTrackingButton?.setTitle(title, for: .normal)
    }
    
    private func updateLocationDisplay(_ location: CLLocation) {
        locationLabel?.text = "Latitude: \(location.coordinate.latitude)\nLongitude: \(location.coordinate.longitude)"
    }
    
    private func updateAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            statusLabel?.text = "Location permission granted"
        case .denied:
            statusLabel?.text = "Location permission denied"
            isTracking = false
            updateTrackingButtonState()
        case .restricted:
            statusLabel?.text = "Location access is restricted"
        case .notDetermined:
            statusLabel?.text = "Waiting for permission..."
        @unknown default:
            statusLabel?.text = "Unknown authorization status"
        }
    }
}

extension MainViewController: MainViewModelDelegate {
    func didUpdateLocation(_ location: CLLocation) {
        updateLocationDisplay(location)
    }
    
    func didChangeAuthorizationStatus(_ status: CLAuthorizationStatus) {
        updateAuthorizationStatus(status)
    }
    
    func didFailWithError(_ error: Error) {
        let alertController = UIAlertController(
            title: "Location Error",
            message: "Failed to get location: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
