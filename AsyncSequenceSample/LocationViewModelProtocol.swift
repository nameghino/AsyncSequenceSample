//
//  LocationViewModelProtocol.swift
//  AsyncSequenceSample
//
//  Created by Nicolas Ameghino on 1/30/26.
//

import Combine
import CoreLocation

protocol LocationViewModelProtocol: ObservableObject {
    var locationManager: CLLocationManager { get }
    var location: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
}

extension LocationViewModelProtocol {
    func requestPermissionIfNeeded() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdates() {
        locationManager.stopUpdatingLocation()
    }

    var isAuthorized: Bool {
        authorizationStatus.isAuthorized
    }
}

extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        switch self {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            return true
        @unknown default:
            return false
        }

    }
}
