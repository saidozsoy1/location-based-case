//
//  MainViewModel.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 19.04.2025.
//

final class MainViewModel {
    private let locationManager: LocationManaging

    init(locationManager: LocationManaging) {
        self.locationManager = locationManager
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
}
